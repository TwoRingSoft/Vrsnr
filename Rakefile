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
    build = `vrsn --file Vrsnr/Config/Project.xcconfig --read --numeric --key BUILD_VERSION`
    sh "git tag #{version.strip}+b#{build.strip}"
    sh "git push"
    sh "git push --tags"
end
