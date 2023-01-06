addSbtPath () {
  addToSearchPath SBT_PATH "$1/lib/ivy2/local"
}

addEnvHooks "$hostOffset" addSbtPath
