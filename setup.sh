#this file will get variables from the ENV for the project
PROJECT_NAME="${PROJECT_NAME:=BLT}"
IDENTIFIER="${IDENTIFIER:=com.apps.bltflutter}"
sed -i 's/com.apps.bltflutter/${IDENTIFIER}/g' android/app/build.gradle
