function ghb --wraps='gh repo view --web' --description 'alias ghb=gh repo view --web'
  gh repo view --web $argv;
end