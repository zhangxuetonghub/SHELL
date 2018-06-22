for i in `docker images | awk '{print $1;}'`;do 
    if [ $i == REPOSITORY ]; then 
        continue
    else 
        docker save -o ${i#*/}.tar $i
    fi 
done
