require 'rake/clean'

CLEAN.include('*~')
FILES_TO_TIDY = [ '*.xml', '*.rb', 'Rakefile' ]

desc "Set permissions to 644"
task :permissions do
  system "find . -type f -print0 | xargs -0 chmod 644"
end

desc "Check for valid XML and Ruby"
task :check do
  system "find . -name '*.xml' -print0 | xargs -0 xmllint --noout"
  system "find . -name '*.rb' -print0 | xargs -0 ruby -c"
end

desc "Tidy lineendings and empty spaces"
task :tidy do
  system "find . -name '*.xml' -print0 | xargs -0 fromdos"
  FILES_TO_TIDY.each do |f|
    system "find . -name '#{f}' -print0 | xargs -0 sed -i 's/[ \t]*$//g'"
  end
end

desc "Create package list"
task :package_list do
  system %q[ grep name= *.xml | grep -v variable | cut -f2 -d '"' | sort -u | todos > package_list.txt ]
end

task :default => [:clean, :permissions, :tidy, :check ]
