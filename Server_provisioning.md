# Initializing a new server for Ember Observer

## The steps
1. Create a basic Ubuntu 14.04 host.
2. Log in as root and add your SSH public key to the root user's `.ssh/authorized_keys` file. [Note that a Digital Ocean droplet can be created with this already set up.]
3. Set the new machine's hostname. There are three parts to this: setting it in `/etc/hostname`, adding it to the `127.0.0.1` entry in `/etc/hosts`, and running the `hostname` command. [Note that Digital Ocean droplets will already be set up with the hostname given at creation.]
4. Back on your local machine, set up a file with `name=value` pairs for required fields. The simplest way to do this is to copy the `.env` file from the existing production server and make changes as required. You will need to add a `SUDO_PASSWORD` entry.
5. Run the `server_init.bash` script, passing the hostname or IP of the new server and the name of the file created in step 4 as command-line arguments.
6. Wait for the script to exit, then run it again. Yes, I know, it's weird; for some reason the first run bails out after installing packages, and the second run then runs to completion.
7. Deploy the server code. (`cap <environment> deploy`, where `environment` specifies the new server)
8. Deploy the client code. (`./deploy.sh` in the client repo; you'll want to change the hostname in there to that of the new server)

At this point, you'll have a fully set up production configured server, but it won't have any data.
The addon update process will automatically run as usual, and populate basic data, but stuff like reviews won't exist.
To make a copy of the existing production database and import it on the new server, use the `import_database.bash` script.
First, open it and edit the variables at the top to reflect the current reality.
Then run `./import_database.bash` and sit back.

## List of required config values
* `BACKUP_SNITCH_URL`
** URL for the [Dead Man's Snitch](https://deadmanssnitch.com/) that monitors the backup job
* `BUGSNAG_API_KEY`
** API key for Bugsnag
* `EMBER_OBSERVER_DATABASE_PASSWORD`
** Password to use for setting up the `ember_observer` user in the new database
* `FETCH_SNITCH_ID`
** ID of the Dead Man's Snitch that monitors the NPM fetch process
* `GITHUB_ACCESS_TOKEN`
** Github access token
* `MANDRILL_USERNAME`
** Username for [Mandrill](https://mandrillapp.com/)
* `MANDRILL_PASSWORD`
** Password for the Mandrill user
* `SUDO_PASSWORD`
** Password that will be set for the `eo` user on the new server (used for `sudo`)
* `UPDATE_SNITCH_ID`
** ID of the Dead Man's Snitch that monitors the whole update process
