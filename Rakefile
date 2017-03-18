task :update_baselines do
	sh 'find Vrsnr/vrsnTests/results/ -name "*.results" | xargs -I @ mv @ Vrsnr/vrsnTests/baseLines/'
end

task :test do
	sh 'Scripts/test.sh'
end
