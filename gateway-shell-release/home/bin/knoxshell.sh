#!/usr/bin/env bash
# shellcheck disable=SC1090
#
#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# The app's label
export APP_LABEL=KnoxShell

# Start/stop script location
APP_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup the common environment
. "$APP_BIN_DIR"/knox-env.sh

# Source common functions
. "$APP_BIN_DIR"/knox-functions.sh

# The app's jar name
APP_JAR="$APP_BIN_DIR/knoxshell.jar"

# The app's logging options
APP_LOG_OPTS="$KNOX_SHELL_LOG_OPTS"

# The app's memory options
APP_MEM_OPTS="$KNOX_SHELL_MEM_OPTS"

# The app's debugging options
APP_DBG_OPTS="$KNOX_SHELL_DBG_OPTS"

# JAVA options used by the JVM
export APP_JAVA_OPTS="$APP_JAVA_LIB_PATH $APP_MEM_OPTS $APP_DBG_OPTS $APP_LOG_OPTS"

function main {
   checkJava

   #printf "Starting $APP_LABEL \n"
   #printf "$@"
   case "$1" in
      init|buildTrustStore)
        if [ "$#" -ne 2 ]; then
            echo "Illegal number of parameters."
            printHelp
        else
          $JAVA -cp "$APP_JAR" org.apache.knox.gateway.shell.KnoxSh "$1" --gateway "$2" || exit 1
        fi
         ;;
      list|destroy)
        "$JAVA" -cp "$APP_JAR" org.apache.knox.gateway.shell.KnoxSh "$1" || exit 1
         ;;
      help)
         printHelp
         ;;
      *)
         $JAVA "$APP_JAVA_OPTS" -jar "$APP_JAR" "$@" || exit 1
         ;;
   esac
   
   return 0
}

function printHelp {
   echo ""
   echo "Apache Knox Client Shell"
   echo "The client shell facility provide a CLI for establishing and managing Apache Knox Sessions"
   echo "and executing the Apache Knox groovy-based DSL scripts. It may also be used to enter an"
   echo "interactive shell where groovy-based DSL and groovy code may be entered and executed in realtime."
   echo ""
   echo "knoxshell usage: "
   echo "   knoxshell.sh [[buildTrustStore <knox-gateway-url>|init <topology-url>|list|destroy|help] | [<script-file-name>]]"
   echo "   ----------------------------------------------------------"
   echo "   buildTrustStore <knox-gateway-url> - downloads the given gateway server's public certificate and builds a trust store to be used by KnoxShell"
   echo "        example: knoxshell.sh buildTrustStore https://localhost:8443/"
   echo "   init <topology-url> - requests a session from the knox token service at the url"
   echo "        example: knoxshell.sh init https://localhost:8443/gateway/sandbox"
   echo "   list - lists the details of the cached knox session token"
   echo "        example: knoxshell.sh list"
   echo "   destroy - removes the cached knox session token"
   echo "        example: knoxshell.sh destroy"
   echo "   <script-file-name> - executes the groovy script file"
   echo "        example: knoxshell.sh ~/bin/ls.groovy"
   echo ""
   return 0
}

#Starting main
main "$@"
