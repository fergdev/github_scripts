# Function to create a github repo
# Thnks to https://www.viget.com/articles/create-a-github-repo-from-the-command-line for inspiration with github tokens

function checkCredentials(){
  user_name=`git config github.user`
  if [ -z "$user_name" ]; then
    echo "User name not set in git config try \"git config github.user USERNAME\""
    return 1

  fi
 
  git_token=`git config github.token`
  if [ -z "$git_token" ]; then
    echo "Git token not set in git config try \"git config github.token TOKEN\""
    echo "You can create a git token on github under settings/personal_acces_tokens"
    return 1
  fi
}


function createRepo(){
  repo_name=$1

  checkCredentials
  if [ $? -eq 1 ]; then
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
  #curl -u "$user_name" https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"
  curl -u "$user_name:$git_token" https://api.github.com/user/repo -d "{\"name\":\"$repo_name\"}" > /dev/null 2>&1
  git remote add origin git@github.com:$user_name/$repo_name.git > /dev/null 2>&1
  git push -u origin master /dev/null 2>&1
  echo "done"
} 

function createGist(){
  gist_files=$1
  gist_description=$2
  gist_is_public=$3

  checkCredentials
  if [ $? -eq 1 ]; then
    return 1
  fi

  if [ -z "$gist_files" ]; then
    echo "Gist files is empty"
    return
  fi

  if [ -z "$gist_description" ]; then
    echo "Gist description is empty"
    return
  fi

  if [ -z "$gist_is_public" ]; then
    echo "Gist is public is empty"
    return
  fi
  echo "Creating gist ${gist_files}, ${gist_description}, ${gist_is_public}"
  curl -X POST -u "$user_name:$git_token" https://api.github.com/gists -d '{"description":"'"${gist_description}"'","public":"'"${gist_is_public}"'","files":{"file1.txt":{"content":"String file contents"}}}' 
}
