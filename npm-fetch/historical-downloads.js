const https = require('https');
const fs = require('fs').promises;

const MAX_RETRIES = 5;
const RETRY_DELAY_MS = 1000;

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve({
        statusCode: res.statusCode,
        data,
        headers: res.headers
      }));
    }).on('error', reject);
  });
}

async function fetchWithRetries(packageName, attempts = 0) {
  const url = `https://api.npmjs.org/downloads/range/last-month/${packageName}`;
  try {
    console.log(`Fetching ${packageName}...`);
    const { statusCode, data, headers } = await httpsGet(url);

    if (statusCode === 200) {
      return JSON.parse(data);
    }

    if (statusCode === 404) {
      return null;
    }

    if (statusCode === 429 || statusCode >= 500) {
      if (attempts >= MAX_RETRIES) {
        throw new Error(`HTTP ${statusCode} after ${MAX_RETRIES} retries fetching ${packageName}`);
      }

      let delay = RETRY_DELAY_MS * Math.pow(2, attempts);

      if (headers['retry-after']) {
        const retryAfter = headers['retry-after'];
        console.log(`Retry-After header: ${retryAfter}`);

        // Retry-After can be in seconds or a date
        const retryAfterSeconds = parseInt(retryAfter);
        if (!isNaN(retryAfterSeconds) && retryAfterSeconds > 0) {
          delay = retryAfterSeconds * 1000;
        } else {
          const retryAfterDate = new Date(retryAfter);
          if (!isNaN(retryAfterDate.getTime())) {
            const calculatedDelay = retryAfterDate.getTime() - Date.now();
            if (calculatedDelay > 0) {
              delay = calculatedDelay;
            }
          }
        }
      }

      console.log(`Rate limited or server error (${statusCode}), retrying ${packageName} in ${delay}ms...`);
      await sleep(delay);
      return fetchWithRetries(packageName, attempts + 1);
    }

    throw new Error(`HTTP ${statusCode}: ${data}`);
  } catch (err) {
    if (attempts >= MAX_RETRIES) {
      throw err;
    }
    const delay = RETRY_DELAY_MS * Math.pow(2, attempts);
    console.log(`Request error fetching ${packageName}, retrying in ${delay}ms...`);
    await sleep(delay);
    return fetchWithRetries(packageName, attempts + 1);
  }
}

async function main() {
  try {
    const packageNamesData = await fs.readFile('/tmp/addon-names.json', 'utf8');
    const packageNames = JSON.parse(packageNamesData);

    const results = [];

    for (const packageName of packageNames) {
      try {
        const data = await fetchWithRetries(packageName);
        results.push({ status: 'fulfilled', value: data });
      } catch (err) {
        console.error('WARN: failed to get download data for', packageName);
        console.error(err);
        results.push({ status: 'rejected', reason: err });
      }

      await sleep(10);
    }

    const downloadData = results
      .filter(result => result.status === 'fulfilled' && result.value !== null)
      .map(result => result.value);

    await fs.writeFile('/tmp/addon-downloads.json', JSON.stringify(downloadData));
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

main();
