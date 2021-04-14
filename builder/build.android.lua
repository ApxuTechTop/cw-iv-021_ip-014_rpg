os.execute("echo %CD% > tmp.txt")
local f = io.open("tmp.txt", "r")
local cwd = f:read("*l")
io.close(f)
os.remove("tmp.txt")
cwd = cwd:sub(1, cwd:len()-1)
local params =
{
	platform='Android',
	appName='Similarity',
	appVersion='1.0',
	dstPath=cwd ..'/bin',
	sdkPath='C:/Users/ApxuTechTop/AppData/Roaming/Corona Labs/Corona Simulator/Android Build/sdk',
	projectPath=cwd ..'/Similarity',
	androidAppPackage='com.coronalabs.Similarity',
	
	-- Following are optional:
	--[[
	certificatePath='/path/to/cert.keystore',
	keystorePassword='',
	keystoreAlias='',
	keystoreAliasPassword='',
	androidVersionCode=1,
	--]]
}
return params