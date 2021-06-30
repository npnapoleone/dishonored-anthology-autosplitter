state("Dishonored")
{

}

state("Dishonored", "1.2")
{
	float x : 0xFCCBDC, 0xC4;
	int levelNumber : 0xFB7838, 0x2C0, 0x314, 0x0, 0x38;
	string64 movie : 0xFC6AD4, 0x48, 0x0;
	bool cutsceneActive : 0xFB51CC, 0x744;
	bool isLoading : "binkw32.dll", 0x312F4;
	int missionStatsScreenFlags : 0xFDEB08, 0x24, 0x41C, 0x2E0, 0xC4;
}

state("Dishonored", "1.4 Reloaded")
{
	
}

state("Dishonored", "1.4 Steam")
{
	
}

startup {
	vars.autoSplits = new Tuple<string, string, bool>[] {
		Tuple.Create("Prison Start", "L_Prison_P", true),
		Tuple.Create("Sewers Start", "L_PrsnSewer_P", true),
		Tuple.Create("Dishonored End Mission Screen", "mission_stats", true),
		Tuple.Create("Outsider S1", "L_Pub_Day_P", false),
		Tuple.Create("Outsider S2", "L_OutsiderDream_P", false),
		Tuple.Create("Outsider S3", "L_Pub_Dusk_P", false),
		Tuple.Create("Campbell S1", "L_Streets1_P", true),
		Tuple.Create("Campbell S2", "L_Ovrsr_P", false),
		Tuple.Create("Campbell S3", "L_Ovrsr_Back_P", false),
		Tuple.Create("Campbell End Mission Screen", "mission_stats", true),
		Tuple.Create("Weepers S1", "L_Pub_Morning_P", false),
		Tuple.Create("Weepers S2", "L_Pub_Day_P", false),
		Tuple.Create("Golden Cat S1", "L_Streets2_P", true),
		Tuple.Create("Golden Cat S2", "L_Brothel_P", false),
		Tuple.Create("Golden Cat S3", "L_Streets2_P", false),
		Tuple.Create("Golden Cat End Mission Screen", "mission_stats", true),
		Tuple.Create("Bridge I1", "L_Pub_Dusk_P", false),
		Tuple.Create("Bridge S1", "L_Bridge_Part1a_P", false),
		Tuple.Create("Bridge S2", "L_Bridge_Part1b_P", false),
		Tuple.Create("Bridge S3", "L_Bridge_Part1c_P", false),
		Tuple.Create("Bridge S4", "L_Bridge_Part2_P", false),
		Tuple.Create("Bridge End Mission Screen", "mission_stats", true),
		Tuple.Create("Boyle I1", "L_Pub_Night_P", false),
		Tuple.Create("Boyle I2", "L_Pub_Day_P", false),
		Tuple.Create("Boyle S1", "L_Boyle_Ext_P", false),
		Tuple.Create("Boyle S2", "L_Boyle_Int_P", false),
		Tuple.Create("Boyle S3", "L_Boyle_Ext_P", false),
		Tuple.Create("Boyle End Mission Screen", "mission_stats", true),
		Tuple.Create("Tower I1", "L_Pub_Morning_P", false),
		Tuple.Create("Tower S1", "L_TowerRtrn_Yard_P", false),
		Tuple.Create("Tower S2", "L_TowerRtrn_Int_P", false),
		Tuple.Create("Tower S3", "L_TowerRtrn_Yard_P", false),
		Tuple.Create("Tower End Mission Screen", "mission_stats", true),
		Tuple.Create("Flooded I1", "L_Pub_Dusk_P", false),
		Tuple.Create("Flooded I2", "L_Flooded_FIntro_P", false),
		Tuple.Create("Flooded S1", "L_Flooded_FStreets_P", false),
		Tuple.Create("Flooded S2", "L_Flooded_FAssassins_P", false),
		Tuple.Create("Flooded S3", "L_Flooded_FGate_P", false),
		Tuple.Create("Flooded S4", "L_Streetsewer_P", false),
		Tuple.Create("Flooded End Mission Screen", "mission_stats", true),
		Tuple.Create("Loyalists", "L_Pub_Assault_P", false),
		Tuple.Create("Loyalists End Mission Screen", "mission_stats", true),
		Tuple.Create("Kingsparrow S1", "L_Isl_LowChaos_P", false),
		Tuple.Create("Kingsparrow S2", "L_LightH_LowChaos_P", false),
	};

	int i = 0;
	foreach  (var autoSplit in vars.autoSplits) {
		settings.Add("autosplit_" + i.ToString(), autoSplit.Item3, "Split on " + autoSplit.Item1);
		++i;
	}
	settings.Add("autosplit_end", true, "Split on End");

	vars.autoSplitIndex = -1;
}

init {
	version = "1.2";

	if (vars.autoSplitIndex == -1) {
		for (vars.autoSplitIndex = 0; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
			if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
				break;
			}
		}
	}
}

exit {
	timer.IsGameTimePaused = true;
}

isLoading {
	return current.isLoading && current.movie != "Dishonored";
}

update {
	const double posX = 9826.25f, delta = 0.25f;
	if (old.isLoading || current.isLoading) {
		// if we are loading, check for run reset
		int levelNum = current.levelNumber * 4;
		string levelName = new DeepPointer(0xFA3624, levelNum, 0x10).DerefString(game, 32);
		vars.runStarting = levelName.StartsWith("l_tower_p")
			&& posX - delta < current.x
			&& posX + delta > current.x;

		if (vars.runStarting) {
			for (vars.autoSplitIndex = 0; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
				if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
					break;
				}
			}
		}
	} else {
		vars.runStarting = false;
	}
}

reset {
	return current.isLoading && vars.runStarting;
}

start {
	return !current.isLoading && vars.runStarting;
}

split {
	if (vars.autoSplitIndex < vars.autoSplits.Length) {
		// if we are in a loading screen, split if applicable based on level
		int levelNum = current.levelNumber * 4;
		string levelName = new DeepPointer(0xFA3624, levelNum, 0x10).DerefString(game, 32);
		if (current.isLoading && levelName.StartsWith(vars.autoSplits[vars.autoSplitIndex].Item2)) {
			for (++vars.autoSplitIndex; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
				if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
					break;
				}
			}
			return true;
		} else if (old.missionStatsScreenFlags != current.missionStatsScreenFlags &&
		           (current.missionStatsScreenFlags & 1) != 0) {
			// if we are on a mission stat screen, split if applicable
			if (!current.isLoading && vars.autoSplits[vars.autoSplitIndex].Item2.StartsWith("mission_stats")) {
				for (++vars.autoSplitIndex; vars.autoSplitIndex < vars.autoSplits.Length; ++vars.autoSplitIndex) {
					if (settings["autosplit_" + vars.autoSplitIndex.ToString()]) {
						break;
					}
				}
				return true;
			}
		}
	} else if (vars.autoSplitIndex == vars.autoSplits.Length && settings["autosplit_end"]) {
		// if the last remaining split is the end, and we have started the cutscene, split if applicable
		if (!current.isLoading && current.cutsceneActive) {
			++vars.autoSplitIndex;
			return true;
		}
	}
	return false;
}