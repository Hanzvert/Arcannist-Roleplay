#include <YSI_Coding\y_hooks>

#define MAX_GUDANG 10

enum e_gudang
{
	gudangowner[MAX_PLAYER_NAME],
	gudangName[128],
	gudangPrice,
	Float:GudangSposX,
	Float:GudangSposY,
	Float:GudangSposZ,
	Float:GudangSposA,
	gudangkecubung,
	gudangsnack,
	gudanguangMerah,
	gudangmoney,
	//Not Save
	Text3D:gudangLabelSafe,
	gudangPickSafe
};

new gudangData[MAX_GUDANG][e_gudang];
new Iterator:Gudang<MAX_GUDANG>; 

SaveGudang(id)
{
	new dquery[2048];
	format(dquery, sizeof(dquery), "UPDATE farm SET name='%s', owner='%s', price='%s'",
	gudangData[id][gudangName],
	gudangData[id][gudangowner],
	gudangData[id][gudangPrice]);

	format(dquery, sizeof(dquery), "%s, safex='%f', safey='%f', safez='%f', kecubung='%d', kayu='%d', snack='%d', uangmerah='%d' money='%d'",
	dquery,
	gudangData[id][GudangSposX],
	gudangData[id][GudangposY],
	gudangData[id][GudangSposZ],
	gudangData[id][gudangkecubung],
	gudangData[id][gudangsnack],
	gudangData[id][gudanguangMerah],
	gudangData[id][gudangmoney],
	id);
	return mysql_tquery(g_SQL, dquery);
}


RefreshGudang(id)
{
	if(id != -1)
	{			
        if(IsValidDynamicPickup(gudangData[id][gudangPickSafe]))
            DestroyDynamicPickup(gudangData[id][gudangPickSafe]);
		
		new tstr[128];
		if(strcmp(farmData[id][farmLeader], "-"))
		{
			format(tstr, sizeof(tstr), "[ID: %d]\n"WHITE_E"Name: {FFFF00}%s\n"WHITE_E"Owned\n[{FF4040}STORAGE{ffffff}]", id, farmData[id][gudangName]);
			farmData[id][farmLabelSafe] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, farmData[id][FarmSposX], farmData[id][FarmSposY], farmData[id][FarmSposZ], 5.0);
            farmData[id][farmPickSafe] = CreateDynamicPickup(1239, 23, farmData[id][FarmSposX], farmData[id][FarmSposY], farmData[id][FarmSposZ], id, 0, -1, 7);
		}

		format(tstr, sizeof(tstr), "[ID: %d]\n"{FFC500}"STORAGE\n/gudang", id);
		gudangData[id][gudangLabelSafe] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, gudangData[id][GudangSposX], gudangData[id][GudangSposY], gudangData[id][GudangSposZ], 5.0);
        gudangData[id][gudangPickSafe] = CreateDynamicPickup(1239, 23, gudangData[id][GudangSposX], gudangData[id][GudangSposY], gudangData[id][GudangSposZ], id, 0, -1, 7);
	}
}

function OnGudangCreated(id)
{
	SaveGudang(id);
	RefreshGudang(id);
	return 1;
}

function LoadGudang()
{
    new rows = cache_num_rows();
 	if(rows)
  	{
   		new fid;
		for(new i; i < rows; i++)
		{
  			cache_get_value_name_int(i, "ID", fid);
  			cache_get_value_name(i, "name", name);
  			format(gudangData[fid][gudangName], 128, name);
  			cache_get_value_name(i, "leader", leader);
			format(gudangData[fid][gudangowner], MAX_PLAYER_NAME, leader);
			cache_get_value_name_float(i, "gafex", gudangData[fid][GudangSposX]);
			cache_get_value_name_float(i, "gafey", gudangData[fid][GudangSposY]);
			cache_get_value_name_float(i, "gafez", gudangData[fid][GudangSposZ]);
			cache_get_value_name_int(i, "money", gudangData[fid][gudangmoney]);
			cache_get_value_name_int(i, "uangmerah", gudangData[fid][gudanguangMerah]);
			cache_get_value_name_int(i, "snack", gudangData[fid][gudangsnack]);
			cache_get_value_name_int(i, "kecubung", gudangData[fid][gudangKecubung]);
			
			Iter_Add(GUDANG, fid);
			RefreshGudang(fid);
	    }
	    printf("[GUDANG] Number of Gudang loaded: %d.", rows);
	}
}

//----------[ Commands ]-----------

CMD:creategudang(playerid, params[])
{
	if(pData[playerid][pAdmin] < 6)
		return PermissionError(playerid);
		
	new fid = Iter_Free(GUDANG), query[128];
	if(fid == -1) return Error(playerid, "You cant create more Gudang slot empty!");
	new name[50], otherid, query[128];
	if(sscanf(params, "s[50]u", name, otherid)) return Usage(playerid, "/creategudang");
	if(otherid == INVALID_PLAYER_ID)
		return Error(playerid, "invalid playerid.");

	pData[otherid][pGudang] = fid;

	gudangData[fid][GudangSposX] = 0;
	gudangData[fid][GudangposY] = 0;
	gudangData[fid][GudangSposZ] = 0;
	gudangData[fid][gudangkecubung] = 0;
	gudangData[fid][gudangsnack] = 0;
	gudangData[fid][gudangsangMerah] = 0;
	gudangData[fid][gudangmoney] = 0;

	GetPlayerPos(playerid, gudangData[fid][GudangSposX], gudangData[fid][GudangSposY], gudangData[fid][GudangSposZ]);

    SaveGudang(fid);
	RefreshGudang(fid);
		
	SendStaffMessage(COLOR_LRED, "Admin %s has changed the Gudang safepos ID: %d.", pData[playerid][pAdminname], fid);

	Iter_Add(GUDANG, fid);
	
	mysql_format(g_SQL, query, sizeof(query), "INSERT INTO farm SET ID=%d, name='%s', leader='%s'", fid, name, pData[otherid][pName]);
	mysql_tquery(g_SQL, query, "OnGudangCreated", "i", fid);
	return 1;
}

CMD:gudang(playerid)
{	
	new fid;
	if(IsPlayerInRangeOfPoint(playerid, 3.0, gudangData[fid][GudangSposX], gudangData[fid][GudangSposY], gudangData[fid][GudangSposZ]))
    {
     	ShowPlayerDialog(playerid, GUDANG_STORAGE, DIALOG_STYLE_LIST, "Gudang Storage", "Kecubung\nSnack", "Select", "Cancel");
    }
 	else
   	{
     	Error(playerid, "You aren't in range in area Gudang safe.");
    }
	return 1;
}