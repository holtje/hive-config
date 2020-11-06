let List/map = https://prelude.dhall-lang.org/List/map

let k8s =
      https://raw.githubusercontent.com/dhall-lang/dhall-k8s/master/package.dhall sha256:ef3845f617b91eaea1b7abb5bd62aeebffd04bcc592d82b7bd6b39dda5e5d545

let mkTmpDir
    : Text → k8s.Volume.Type
    = λ(name : Text) →
        k8s.Volume::{ emptyDir = Some k8s.EmptyDirVolumeSource::{=}, name }

let namespace
    : Text
    = "docwhat"

let appName
    : Text
    = "blog"

let ServiceConfig
    : Type
    = { env : Text }

let configs
    : List ServiceConfig
    = [ { env = "production" }, { env = "staging" } ]

let oneConfig
    : ServiceConfig
    = { env = "staging" }

let mkDeploy
    : ServiceConfig → k8s.Deployment.Type
    = λ(config : ServiceConfig) →
        k8s.Deployment::{
        , apiVersion = "apps/v1"
        , kind = "Deployment"
        , metadata = k8s.ObjectMeta::{
          , name = Some "${appName}-${config.env}"
          , namespace = Some namespace
          }
        , spec = Some k8s.DeploymentSpec::{
          , selector = k8s.LabelSelector::{
            , matchLabels = Some
                (toMap { app = appName, environment = config.env })
            }
          , template = k8s.PodTemplateSpec::{
            , metadata = k8s.ObjectMeta::{
              , labels = Some
                  (toMap { app = appName, environment = config.env })
              }
            , spec = Some k8s.PodSpec::{
              , containers =
                [ k8s.Container::{
                  , image = Some "ghcr.io/docwhat/blog:sha-45d952e4"
                  , livenessProbe = Some k8s.Probe::{
                    , httpGet = Some k8s.HTTPGetAction::{
                      , path = Some "/nginx-health"
                      , port = k8s.IntOrString.Int 80
                      }
                    }
                  , name = appName
                  , ports = Some [ k8s.ContainerPort::{ containerPort = 80 } ]
                  , readinessProbe = Some k8s.Probe::{
                    , httpGet = Some k8s.HTTPGetAction::{
                      , path = Some "/"
                      , port = k8s.IntOrString.Int 80
                      }
                    }
                  , resources = Some k8s.ResourceRequirements::{
                    , requests = Some (toMap { cpu = "2m" })
                    }
                  , securityContext = Some k8s.SecurityContext::{
                    , readOnlyRootFilesystem = Some True
                    }
                  , volumeMounts = Some
                    [ k8s.VolumeMount::{
                      , mountPath = "/var/cache/nginx"
                      , name = "cache-volume"
                      }
                    , k8s.VolumeMount::{
                      , mountPath = "/run"
                      , name = "run-volume"
                      }
                    ]
                  }
                ]
              , imagePullSecrets = Some
                [ { name = Some "github-docker-secret" } ]
              , volumes = Some
                [ mkTmpDir "cache-volume", mkTmpDir "run-volume" ]
              }
            }
          }
        }

in  { apiVersion = "v1"
    , kind = "List"
    , items = List/map ServiceConfig k8s.Deployment.Type mkDeploy configs
    }
