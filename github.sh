# Function to create a github repo
# Thnks to https://www.viget.com/articles/create-a-github-repo-from-the-command-line for inspiration with github tokens
set -e
# Check dependencies
dependencies=( "curl" "jq" "wwefwefweF")
for dependency in "${dependencies[@]}" ; do
  which "${dependency}"
  if [ $? -eq 1 ]; then
    echo "Dependency not available \"${dependency}\" please install and run this script again"
    return 1 
  fi
done

echo "All dependencies available :) installing functions"


function checkCredentials(){
  github_user_name=`git config github.user`
  if [ -z "$user_name" ]; then
    echo "User name not set in git config try \"git config github.user USERNAME\""
    return 1
  fi
 
  github_git_token=`git config github.token`
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
  curl -u "$github_user_name:$github_git_token" https://api.github.com/user/repo -d "{\"name\":\"$repo_name\"}" > /dev/null 2>&1
  git remote add origin git@github.com:$user_name/$repo_name.git > /dev/null 2>&1
  git push -u origin master /dev/null 2>&1
  echo "Done"
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
  curl -X POST -u "$github_user_name:$github_git_token" https://api.github.com/gists -d '{"description":"'"${gist_description}"'","public":"'"${gist_is_public}"'","files":{"file1.txt":{"content":"String file contents"}}}' 
  echo "Done"
}

function listUserGists(){
  user_name=$1
  since_date=$2

  checkCredentials
  if [ $? -eq 1 ]; then
    return 1
  fi

  if [ -z "$user_name" ]; then
    echo "No user name provided"
    return 1
  fi

  echo "List gists from ${user_name} since ${since_date}"
 
  curl -v -X GET -u "${github_user_name}:${github_git_token}" "https://api.github.com/users/${user_name}/gists" |  jq '.[] | { url: .url }'
}
