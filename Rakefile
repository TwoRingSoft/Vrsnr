desc 'Run tests'
task :test do
	sh 'Scripts/test.sh'
end

desc 'Move new test outputs to the baseline directory to overwrite new correct results.'
task :update_baselines do
    sh 'find Vrsnr/vrsnTests/results/ -name "*.results" | xargs -I @ mv @ Vrsnr/vrsnTests/baseLines/'
end

desc 'Bump either major, minor, patch or build, e.g. rake bump[major].'
task :bump,[:component] do |t, args|
    component = args[:component]
    file = 'Vrsnr/Config/Project.xcconfig'
    if component == 'major' then
        sh "vrsn major --file #{file}"
    elsif component == 'minor' then
        sh "vrsn minor --file #{file}"
    elsif component == 'patch' then
        sh "vrsn patch --file #{file}"
    elsif component == 'build' then
        sh "vrsn --numeric --file #{file} --key BUILD_VERSION"
    else
        fail 'Unrecognized version component.'
    end
end

desc 'Create git tags and push them to remote.'
task :release do
    version = `vrsn --file Vrsnr/Config/Project.xcconfig --read`
    sh "git tag #{version}"
    sh "git push"
    sh "git push --tags"
end
