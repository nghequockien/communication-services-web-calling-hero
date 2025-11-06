#!/bin/sh
set -eu

# Require the ACS connection string to be provided by the environment
: "${RESOURCE_CONNECTION_STRING:?Set RESOURCE_CONNECTION_STRING as an App Setting in Azure}"

# Write Server/appsettings.json from env (don’t bake secrets into the image)
cat > /app/Server/appsettings.json <<EOF
{
  "ResourceConnectionString": "${RESOURCE_CONNECTION_STRING}",
  "EndpointUrl": "",
  "AdminUserId": ""
}
EOF

# Optional: serve the built client statically from Express (if not already in Server code),
# you can add the following snippet into Server startup (see note below):
#   const path = require('path');
#   app.use(express.static(path.join(__dirname, '../Calling/dist')));
#   app.get('*', (req, res) => res.sendFile(path.join(__dirname, '../Calling/dist/index.html')));

# Start the API server (which will also serve the static client if enabled)
