#!/bin/bash

# -L follows redirects
# -O specifies output name
curl -L -o butler.zip https://broth.itch.ovh/butler/darwin-amd64/LATEST/archive/default
mkdir -p butler
unzip -o butler.zip -d butler/
# GNU unzip tends to not set the executable bit even though it's set in the .zip
chmod +x butler/butler
# just a sanity check run (and also helpful in case you're sharing CI logs)
butler/butler -V
rm butler.zip
