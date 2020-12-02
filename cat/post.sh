set -x
curl \
  --header "Authorization: Bearer eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @post.json \
  https://app.terraform.io/api/v2/organizations/Flexera-SE/workspaces