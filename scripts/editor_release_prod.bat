#/bin/bash
source ~/.env
source ~/dlang/dmd-2.087.1/activate

cd ~/src/canvas-js-css/editor

# TODO: update this to use the prod branch? Right now, there is no prod vs stagin editor server, and the code i want to release is still in the staging branch
git checkout staging; git pull origin staging; 

if [ $? -ne 0 ]
then
  echo "Failed pulling staging"
  exit 1;
fi

echo "Compiling editor changes"
make
if [ $? -ne 0 ]
then
  echo "Failed compiling the editor"
  exit 1;
fi

echo "Copying compiled editor binary to target server: $EDITOR_PROD_USER"
scp editor $EDITOR_PROD_USER:/root/canvas-lms-js-css/editor/editor_to_deploy
if [ $? -ne 0 ]
then
  echo "Failed copying editor binary over to target server: $EDITOR_PROD_USER"
  exit 1;
fi

echo "Updating code on target editor server and restarting: $EDITOR_PROD_USER"
# TODO: update this to use the prod branch? Right now, there is no prod vs stagin editor server, and the code i want to release is still in the staging branch
ssh $EDITOR_PROD_USER 'cd /root/canvas-lms-js-css/editor/; git pull upstream staging; killall -9 editor; mv editor_to_deploy editor; nohup /root/canvas-lms-js-css/editor/editor  `</dev/null` >/root/canvas-lms-js-css/editor/nohup.out 2>&1 &'
if [ $? -ne 0 ]
then
  echo "Failed updating code and restarting editor on server: $EDITOR_PROD_USER"
  exit 1;
fi

