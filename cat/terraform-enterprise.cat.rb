name "Terraform Enterprise CAT"
rs_ca_ver 20161221
short_description "Terraform Enterprise CAT"
import 'sys_log'

parameter "param_hostname" do
  label "Hostname"
  type "string"
  default "server1"
end

parameter "param_workspace_id" do
  label "Workspace Id"
  type "string"
  operations "queue_build"
end

output "output_workspace_id" do
  label "Workspace Id"
  category "Terraform"
  default_value $workspace_id
  description "Workspace Id"
end

output "output_workspace_href" do
  label "Workspace href"
  category "Terraform"
  default_value $workspace_href
  description "Workspace href"
end

operation "launch" do
  definition "defn_launch"
  output_mappings do {
    $output_workspace_id => $workspace_id,
    $output_workspace_href => $workspace_href
  } end
end

operation "queue_build" do
  definition "defn_create_runs"
end

operation "terminate" do
  definition "defn_terminate"
end

define defn_launch($param_hostname) return $workspace_href, $workspace_id do
  $tf_cat_token = "eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw"
  $base_url = "https://app.terraform.io/api/v2"

  call defn_create_workspace($tf_cat_token,$base_url,"0.12.29",@@deployment) retrieve $workspace_href, $workspace_id
  call sys_log.detail(join(["Workspace ID: ", $workspace_id, ", HREF: ", $workspace_href]))
  call defn_create_workspace_var($tf_cat_token, $base_url, $workspace_id, "AWS_ACCESS_KEY_ID", cred("AWS_ACCESS_KEY_ID"),"AWS ACCESS KEY", "env", false, false)
  call defn_create_workspace_var($tf_cat_token, $base_url, $workspace_id, "AWS_SECRET_ACCESS_KEY", cred("AWS_SECRET_ACCESS_KEY"),"AWS_SECRET_ACCESS_KEY", "env", false, true)
  call defn_create_workspace_var($tf_cat_token, $base_url, $workspace_id, "hostname", $param_hostname,"hostname of server", "terraform", false, false)
end

define defn_terminate() return $terminate_response do
  $tf_cat_token = "eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw"
  $base_url = "https://app.terraform.io/api/v2"
  call defn_delete_workspace($tf_cat_token,$base_url,@@deployment.name) retrieve $terminate_response
end

define defn_create_workspace($tf_cat_token,$base_url,$tf_version,@deployment) return $workspace_href, $workspace_id do
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
          "terraform-version": $tf_version,
          "vcs-repo": {
            "identifier": "rs-services/tf-cloud",
            "display-identifier": "rs-services/tf-cloud",
            "oauth-token-id": "ot-JjG8EZii7kvFWtUr",
            "branch": "",
            "default-branch": true,
            "ingress-submodules": true
          },
          "vcs-repo-identifier": "rs-services/tf-cloud",
          "auto-apply": true
        }
      }
    },
    url: join([$base_url, "/organizations/Flexera-SE/workspaces"])
  )
  $$create_response = $response
  $$create_body = $response["body"]
  $workspace_href = $$create_body["data"]["links"]["self"]
  $workspace_id = $$create_body["data"]["id"]
end

define defn_delete_workspace($tf_cat_token, $base_url, $name) return $response do
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


define defn_create_workspace_var($tf_cat_token, $base_url, $workspace_id, $key, $value, $description, $category, $hcl, $sensitive) return $create_var_response do
  $var_url = join([$base_url, "/workspaces/", $workspace_id, "/vars"])
  call sys_log.detail($var_url)
  $create_var_response = http_post(
    headers: {
      "Authorization": join(["Bearer ", $tf_cat_token]),
      "Content-Type": "application/vnd.api+json",
      "content-type": "application/vnd.api+json"
    },
    body: {
      "data": {
        "type":"vars",
        "attributes": {
          "key": $key,
          "value": $value,
          "description": $description,
          "category": $category,
          "hcl": $hcl,
          "sensitive": $sensitive
        }
      }
    },
    url: $var_url
  )
  call sys_log.detail($create_var_response)
end

define defn_create_runs($param_workspace_id) return $build_response do
  #https://github.com/hashicorp/terraform-guides/blob/master/operations/automation-script/loadAndRunWorkspace.sh#L262
  $tf_cat_token = "eFzdK7eYeDr3dQ.atlasv1.gTbORMzanGi97xson6NzPs1ScnifTviNZeTcWMK65I7ONgSxMOrMy0XeW4WduzGyhSw"
  $base_url = "https://app.terraform.io/api/v2/runs"
  $build_response = http_post(
    headers: {
      "Authorization": join(["Bearer ", $tf_cat_token]),
      "Content-Type": "application/vnd.api+json",
      "content-type": "application/vnd.api+json"
    },
    body: {
      "data": {
        "attributes": {
          "auto-apply": true,
          "is-destroy": false
        },
        "type":"runs",
        "relationships": {
          "workspace": {
            "data": {
              "type": "workspaces",
              "id": $param_workspace_id
            }
          }
        }
      }
    },
    url: $base_url
  )
end