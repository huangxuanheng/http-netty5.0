SHELL_PROG=./helper.sh
ROOT_HOME=../;export ROOT_HOME
APP_HOME=../classes/;export APP_HOME
LIB_HOME=../lib;export LIB_HOME
CLASSPATH=$ROOT_HOME/classes
for i in "$ROOT_HOME"/lib/*.jar; do
   CLASSPATH="$CLASSPATH":"$i"
done
ulimit -n 20000
MAINPROG=com.lolaage.Main;export MAINPROG
#java -Xdebug -Xrunjdwp:transport=dt_socket,address=6777,server=y,suspend=y -Xms800m -Xmx800m -Xmn256m -Xss256k  -classpath $CLASSPATH $MAINPROG
#java  -Xms800m -Xmx800m -Xmn256m -Xss256k  -classpath $CLASSPATH $MAINPROG
start() {
        echo "[`date`] Begin starting $MAINPROG ... "
        nohup java  -server -Xms1024m -Xmx2048m -Xmn256m -Xss256k -Dcom.sun.management.jmxremote.port=7201  -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.100.60 -XX:ErrorFile=/data/application/helper-netty/bin/java_error_%p.log -classpath $CLASSPATH $MAINPROG 7200 &
        RETVAL=$?
        if [ $RETVAL -eq 0 ]
        then
        echo "[`date`] Startup $MAINPROG successfully."
        else
        echo "[`date`] Startup $MAINPROG fail."
        fi
        return $RETVAL
}
debug() {
        echo "[`date`] Begin starting $MAINPROG... "
        nohup java -Xdebug -Xrunjdwp:transport=dt_socket,address=7777,server=y,suspend=y -Xms10000m -Xmx10000m -Xmn256m -Xss256k  -classpath $CLASSPATH $MAINPROG &
        RETVAL=$?
        if [ $RETVAL -eq 0 ]
        then
        echo "[`date`] Startup $MAINPROG successfully."
        else
        echo "[`date`] Startup $MAINPROG fail."
        fi
        return $RETVAL
}
stop() {
    echo "[`date`] Begin stop $MAINPROG... "
    PROGID=`ps -ef|grep "$MAINPROG"|grep -v "grep"|sed -n '1p'|awk '{print $2" "$3}'`
    kill -9 $PROGID
    RETVAL=$?
    if [ $RETVAL -eq 0 ]
    then
    echo "[`date`] Stop $MAINPROG successfully."
    else
    echo "[`date`] Stop $MAINPROG fail."
    fi
    return $RETVAL
}
case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
restart)
  stop
  start
  ;;
debug)
  debug
  ;;
*)
  echo "[`date`] Usage: $SHELL_PROG {start|debug|stop|restart}"
  exit 1
  ;;
esac

exit 0
