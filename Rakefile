FILES_TO_CLEAN = [ '*.xml', '*.rb', 'Rakefile' ]

desc "Remove backup files"
task :remove_backup do
  system "find . -type f -name '*~' -delete"
end

desc "Set permissions to 644"
task :permissions do
  system "find . -type f -print0 | xargs -0 chmod 644"
end

desc "Check for valid XML and Ruby"
task :check do
  system "find . -name '*.xml' -print0 | xargs -0 xmllint --noout"
  system "find . -name '*.rb' -print0 | xargs -0 ruby -c"
end

desc "Clean lineednings and empty spaces"
task :clean do
  system "find . -name '*.xml' -print0 | xargs -0 fromdos"
  FILES_TO_CLEAN.each do |f|
    system "find . -name '#{f}' -print0 | xargs -0 sed -i 's/[ \t]*$//g'"
  end
end

desc "Create package list"
task :package_list do
  system %q[ grep name= *.xml | grep -v variable | cut -f2 -d '"' | sort | uniq | todos > package_list.txt ]
end

task :default => [:remove_backup, :permissions, :check, :clean ]
