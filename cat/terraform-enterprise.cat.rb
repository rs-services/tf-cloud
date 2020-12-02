name "Terraform Enterprise CAT"
rs_ca_ver 20161221
short_description "Terraform Enterprise CAT"
import 'sys_log'


operation "launch" do
  definition "defn_launch"
end

operation "terminate" do
  definition "defn_terminate"
end

define defn_launch() return $response,$workspace do
  $tf_cat_token = "eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw"
  $base_url = "https://app.terraform.io/api/v2"
  $response = http_get(
    headers: {
      "Authorization": join(["Bearer ", $tf_cat_token]),
      "Content-Type": "application/vnd.api+json"
    },
    url: join([$base_url, "/organizations/Flexera-SE/workspaces/Flexera-SE-API"])
  )
  call defn_create_workspace($tf_cat_token,$base_url,"0.12.29",@@deployment) retrieve $workspace
end

define defn_terminate() return $terminate_response do
  $tf_cat_token = "eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw"
  $base_url = "https://app.terraform.io/api/v2"
  call defn_delete_workspace($tf_cat_token,$base_url,@@deployment.name) retrieve $terminate_response
end

define defn_create_workspace($tf_cat_token,$base_url,$tf_version,@deployment) return $workspace do
  $response = http_post(
    headers: {
      "Authorization": join(["Bearer ", $tf_cat_token]),
      "Content-Type": "application/vnd.api+json",
      "content-type": "application/vnd.api+json"
    },
    body: {
      "type": "workspaces",
      "data": {
        "attributes": {
          "name": @deployment.name,
          "terraform-version": $tf_version
        }
      }
    },
    url: join([$base_url, "/organizations/Flexera-SE/workspaces"])
  )
  $$create_response = $response
  $$create_body = $response["body"]
  $workspace = $$create_body["data"]["links"]["self"]
end

define defn_delete_workspace($tf_cat_token,$base_url, $name) return $response do
  $delete_url = join([$base_url, "/organizations/Flexera-SE/workspaces/", $name])
  call sys_log.detail(join(["Delete URL: ", to_s($delete_url)]))
  $response = http_delete(
    headers: {
      "Authorization": join(["Bearer ", $tf_cat_token]),
      "Content-Type": "application/vnd.api+json",
      "content-type": "application/vnd.api+json"
    },
    url: $delete_url
  )
  call sys_log.detail(to_s($terminate_response))
end