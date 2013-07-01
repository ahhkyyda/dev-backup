
src="/home/work/dynamic_data/restart/model.new"
dst="/home/work/dynamic_data/retrms/model"

cmd = "[ -d #{src} ] && rm -rf #{dst}.bak && mv #{dst} #{dst}.bak && mv #{src} #{dst}"

p cmd
