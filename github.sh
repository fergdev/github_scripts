

function createRepo(){
  user_name=$1
  repo_name=$2
  if [ -z "$user_name" ]; then
    echo "User name not set"
    return 1
  fi

  if [ -z "$repo_name" ]; then
    echo "Repo name not set"
    return 1
  fi

  echo "Creating repo \"${repo_name}\" for \"${user_name}\""

  git init
  touch README.md
  git add README.md
  git commit -m 'Initial commit'
  curl -u "$user_name" https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"
  git remote add origin "git@github.com:${user_name}/${repo_name}.git"
  git push origin master
} 


