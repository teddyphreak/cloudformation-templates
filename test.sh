for i in *.template; do
  aws cloudformation validate-template --template-body file://$i;
  if [ $? -neq 0 ]; then
    echo "Error validating file $i";
    exit 1;
  fi;
done;