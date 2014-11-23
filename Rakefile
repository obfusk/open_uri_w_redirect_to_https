desc 'Run specs'
task :spec do
  sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  sh 'rspec -cfd --tty | less -R'
end

desc 'Run specs w/ coverage'
task :coverage do
  ENV['COVERAGE'] = 'yes'; Rake::Task['spec'].execute
end

desc 'Check for warnings'
task :warn do
  reqs = %w{ config }.map { |x| "-r open_uri_w_redirect_to_https/#{x}" } * ' '
  sh "ruby -w -I lib #{reqs} -e ''"
end

desc 'Check for warnings in specs'
task 'warn:spec' do
  reqs = Dir['spec/**/*.rb'].sort.map { |x| "-r ./#{x}" } * ' '
  sh "ruby -w -I lib -r rspec #{reqs} -e ''"
end

desc 'Check for warnings in specs (but not void context)'
task 'warn:spec:novoid' do
  sh 'rake warn:spec 2>&1 | grep -v "void context"'
end

desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end

desc 'Cleanup'
task :clean do
  sh 'rm -rf .yardoc/ coverage/ doc/ *.gem Gemfile.lock'
end

desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/open_uri_w_redirect_to_https/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build open_uri_w_redirect_to_https.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/open_uri_w_redirect_to_https/version.rb'
end
