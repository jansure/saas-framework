--
-- Created by IntelliJ IDEA.
-- User: pkpm
-- Date: 2019/1/10
-- Time: 16:42
-- To change this template use File | Settings | File Templates.
--
foreign_env = 'grey'
china_env = 'prd'
abtest_num = 50   --流量比率
local num = math.random(100);
if (num <= abtest_num) then
    ngx.log(ngx.INFO,'use foreign environment',foreign_env)
    ngx.exec("@"..foreign_env)
else
    ngx.log(ngx.INFO,'use foreign environment',china_env)
    ngx.exec("@"..china_env)
end

