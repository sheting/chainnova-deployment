#!/bin/bash

START=$(date +"%s")

echo '*** CHECK PARA ***'
if [[ $REPOSITORY == "" || __TAG == "" || __MODE_TYPE == "" || WDIR == ""  ]]; then
    echo "!!!Error: Missing para. REPOSITORY OR TAG. Component Name: $1"
    exit 1
fi

BASE_TAG="0.0.3"
IMAGE_LOCAL="$REPOSITORY:$__TAG"
MODE_TYPE=${__MODE_TYPE}

echo
echo "##############################"
echo "##### get jar from pom.xml"
echo "##############################"
artifactId=$(docker run --rm -v $(pwd)/$SRC_PATH/pom.xml:/usr/src/pom.xml chainnova/config-template:0.0.1 -c "xpath -e '/project/artifactId//text()' /usr/src/pom.xml 2>/dev/null")
version=$(docker run --rm -v $(pwd)/$SRC_PATH/pom.xml:/usr/src/pom.xml chainnova/config-template:0.0.1 -c "xpath -e '/project/version//text()' /usr/src/pom.xml 2>/dev/null")
packaging=$(docker run --rm -v $(pwd)/$SRC_PATH/pom.xml:/usr/src/pom.xml chainnova/config-template:0.0.1 -c "xpath -e '/project/packaging//text()' /usr/src/pom.xml 2>/dev/null")
packaging=${packaging:-'jar'}
if [[ $version == "" || $artifactId == "" || $packaging == "" ]]; then
    echo "!!!Error: Missing para. version($version) OR artifactId($artifactId) OR packaging($packaging)"
    exit 1
fi
JAR_NAME=$artifactId"-"$version"."$packaging
echo "JAR_NAME:$JAR_NAME"

echo
echo "##############################"
echo "##### build dependent images"
echo "##############################"
BASE_REPOSITORY=$REPOSITORY"-base"
BASE_IMAGE_LOCAL="$BASE_REPOSITORY:$BASE_TAG"
docker images | grep -q -E "^$BASE_REPOSITORY\s+$BASE_TAG\s+"
if [ $? != 0 ]; then
    echo "Need to rebuild $BASE_IMAGE_LOCAL"
    docker build -f ../../deploy_java/Dockerfile_base -t $BASE_IMAGE_LOCAL ../../deploy_java
    if [ $? != 0 ]; then
        echo "!!!Error: Build $BASE_IMAGE_LOCAL failed."
        exit 1
    fi
else
    echo "No need to rebuild $BASE_IMAGE_LOCAL"
fi

echo
echo "##############################"
echo "##### mvn clean package"
echo "##############################"
if [ -f "$(pwd)/$SRC_PATH/../maven-repo-setting/settings.xml" ]; then 
    MAVEN_SETTING_VOL="-v $(pwd)/$SRC_PATH/../maven-repo-setting/settings.xml:/usr/share/maven/conf/settings.xml"
else
    echo "!!!Waring:no special maven-setting, using the default"
fi

if [ -f "$(pwd)/$SRC_PATH/../maven-dependency/build_script.sh" ]; then 
    echo "Using the special build script: $(pwd)/$SRC_PATH/../maven-dependency/build_script.sh"
    docker run --rm -e MODE_TYPE=$MODE_TYPE -v $(pwd)/$SRC_PATH:/usr/src -v $(pwd)/$SRC_PATH/../maven-dependency/:/usr/src/maven-dependency/ -v $(pwd)/$SRC_PATH/../maven-dependency/build_script.sh:/usr/src/build_script.sh -v /opt/maven-repo-mirror/repository:/root/.m2/repository $MAVEN_SETTING_VOL -w /usr/src/ maven:3.5-jdk-8 ./build_script.sh
    if [ $? != 0 ]; then
        echo "!!!Error: mvn .jar failed."
        exit 1
    fi
else
    docker run --rm -e project.basedir='/usr/src' -v $(pwd)/$SRC_PATH:/usr/src -v /opt/maven-repo-mirror/repository:/root/.m2/repository $MAVEN_SETTING_VOL -w /usr/src/ maven:3.5-jdk-8 mvn -U -Dmaven.test.skip=true -f /usr/src/pom.xml clean package install
    if [ $? != 0 ]; then
        echo "!!!Error: mvn .jar failed."
        exit 1
    fi
fi

echo
echo "##############################"
echo "##### build images"
echo "##############################"
#remove old image
docker rmi -f $IMAGE_LOCAL &> /dev/null
docker images | grep -q -E "^$REPOSITORY\s+$TAG\s+"
if [ $? == 0 ]; then
    echo "!!!Error: Remove old image failed."
    exit 1
fi

#mv ${SRC_PATH}deploy ${SRC_PATH}deploy-bak
cp -R ../../deploy_java $SRC_PATH/deploy
#build image
docker build --no-cache --build-arg BASE_REPOSITORY=$BASE_REPOSITORY --build-arg BASE_TAG=$BASE_TAG --build-arg MODE_TYPE=$MODE_TYPE --build-arg JAR_NAME=$JAR_NAME --build-arg PORT=$PORT -f ../../deploy_java/Dockerfile -t $IMAGE_LOCAL ./$SRC_PATH
if [ $? != 0 ]; then
    echo "!!!Error: Build $IMAGE_LOCAL failed."
    exit 1
fi
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

#push image
if [[ $PUSH_IMAGE == "true" ]]; then
    cd $SCRIPT_DIR
    ./push_image.sh $IMAGE_LOCAL
    if [ $? != 0 ]; then
        echo "!!!Error: Push image failed."
        exit 1
    fi
    cd - &> /dev/null
fi

rm -rf $SRC_PATH/deploy
rm -rf $SRC_PATH/target

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"
exit 0
