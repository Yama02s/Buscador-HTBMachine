#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${blueColour}[!] Saliendo del scrip...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl+C salida del scrip
trap ctrl_c INT
#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

#funciones
function helpPanel(){
  echo -e "\n${redColour}[+]${endColour} Uso:"
  echo -e "\t${yellowColour}u)${endColour} ${redColour}Actualizar o Descargar archivos necesarios${endColour}"
  echo -e "\t${yellowColour}m)${endColour} ${redColour}Buscar por un nombre de maquina${endColour}"
  echo -e "\t${yellowColour}i)${endColour} ${redColour}Buscar maquina por direccion ip${endColour}"
  echo -e "\t${yellowColour}y)${endColour} ${redColour}Buscar enlace del video de la maquina${endColour}"
  echo -e "\t${yellowColour}d)${endColour} ${redColour}Buscar por la dificultad de una maquina${endColour}"
  echo -e "\t${yellowColour}o)${endColour} ${redColour}Buscar el Sistema Operativo de una maquina${endColour}"
  echo -e "\t${yallowColour}s)${endColour} ${redColour}Buscar por skills ${endColour}"
  echo -e "\t${yellowColour}h)${endColour} ${redColour}Mostrar este panel de ayuda${endColour}\n"
}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//')"
  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} Listando las propiedades de la maquina${redColour} $machineName ${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d "," | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function updateFiles(){
  if [ ! -f bundle.js  ]; then
    tput civis
    echo -e "\n${redColour}[+]${endColour} Descargando archivos necesarios..."
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${redColour}[*] ${endColour}Los archivos descargados han finalizado :)"
    tput cnorm
  else
    echo -e "\n${redColour}[+]${endColour}comprobando si hay actualizaciones pendientes..."
    sleep 2

    tput civis
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js| sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    if  [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${redColour}[+]${endColour} No hay actualizaciones :3"
      rm bundle_temp.js
    else
      echo -e "\n${redColour}[+]${endColour} Hay Actualizaciones :c"
      sleep 2
      rm bundle.js && mv bundle_temp.js bundle.js
    echo -e "\n${redColour}[+]${endColour} Los archivos han sido actualizados"
    fi
    tput cnorm
  fi
  }

  function searchIP(){
    ipAddress="$1"
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
    if [ "$machineName" ]; then
      echo -e "\n${yellowColour}[+]${endColour} La maquina correspondiente para la ip ${redColour}$ipAddress${endColour} es ${redColour}$machineName${endColour}\n"
      searchMachine $machineName
    else
      echo -e "\n${redColour}[!] La ip proporcionada no existe :(${endColour}"
    fi
  }  

  function getYoutubeLink(){
    machineName="$1"
    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
    if [ $youtubeLink ]; then
      echo -e "\n${yellowColour}[+]${endColour} La maquina con su tutorial esta en el siguiente enlace: $youtubeLink"

    else
      echo -e "\n${redColour}[!] La maquina proporcionada no existe ;(${endColour}\n"
    fi
  }

  function getMachinesDifficulty(){
    Difficulty="$1"
    resultados_check="$(cat bundle.js | grep "dificultad: \"$Difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$resultados_check" ]; then
      echo -e "\n${yellowColour}[+]${endColour} Representando las maquinas que posee un nivel de dificultad${redColour} $Difficulty $endColour\n"
      cat bundle.js | grep "dificultad: \"$Difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

    else
      echo -e "${redColour}[!] Dificultad no existe${endColour}"
    fi
  }

  function getOSMachines(){
    os="$1"
    resultados_os="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$resultados_os" ]; then
      echo -e "\n${yellowColour}[+]${endColour} Mostrando las maquinas que su Sistema Operativo sea ${purpleColour}$os${endColour}:"
      cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "\n ${redColour}[!] El sistema operativo indicado no existe${endColour}"
    fi
  }

  function getOSDiffMachines(){
    Difficulty="$1"
    os="$2"
    checar_resultados="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$Difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$checar_resultados" ]; then
      echo -e "\n${yellowColour}[+]${endColour} Listando maquinas de dificultad ${redColour}$Difficulty${endColour} que tengan un Sistema Operativo de ${redColour}$os${endColour}"
      cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$Difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "\n${redColour}[!] El Sistema Operativo o la dificultad no es encontrado...${endColour}"
    fi
  }

  function skillsMachines(){
    skills="$1"
    checar_skills="$(cat bundle.js | grep "skills: " -B 6| grep "$skills" -B 6 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$checar_skills" ]; then
      echo -e "\n${yellowColour}[+]${endColour} A Continuacion se representara la maquina donde se requiera esta skill: ${redColour}$skills${endColour}"
      cat bundle.js | grep "skills: " -B 6 | grep "$skills" -B 6 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "\n${redColour}[!] No se han encontrado ninguna skill indicada${endColour}"
    fi
  }
#atajos
declare -i atajos_difficulty=0
declare -i atajos_os=0

#indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) Difficulty="$OPTARG"; atajos_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; atajos_os=1; let parameter_counter+=6;;
    s) skills="$OPTARG"; let parameter_counter+=7;;
    h) helpPanel;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $Difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $atajos_difficulty -eq 1 ]  && [ $atajos_os -eq 1 ]; then
  getOSDiffMachines $Difficulty $os
elif [ $parameter_counter -eq 7 ]; then
  skillsMachines "$skills"
else
  helpPanel
fi

