README [![CircleCI](https://circleci.com/gh/emberobserver/server.svg?style=svg)](https://circleci.com/gh/emberobserver/server) [![codecov](https://codecov.io/gh/emberobserver/server/branch/master/graph/badge.svg)](https://codecov.io/gh/emberobserver/server)

[![View performance data on Skylight](https://badges.skylight.io/status/NOOYkniWkQWj.svg)](https://oss.skylight.io/app/applications/NOOYkniWkQWj)
======
To manually update packages, run `rake npm:update`.  Make sure to run `npm install` in the `npm-fetch` directory first.

## Database

### Loading a production database in development

* bunzip2 ember-observer.2017-12-13.sql.bz2
* rails db:drop
* rails db:create
* psql -d ember_addon_review_development -f ember-observer.2017-12-13.sql
