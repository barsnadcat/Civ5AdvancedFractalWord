
include("MapGenerator");
include("FractalWorld");
include("FeatureGenerator");
include("TerrainGenerator");

------------------------------------------------------------------------------
function GetMapScriptInfo()
	return {
		Name = "Advanced",
		Description = "Coplete control of generators",
		IsAdvancedMap = true,
		IconIndex = 17,
		CustomOptions = 
		{
			{
				Name = "Continent grain",
				Values = 
				{
					"1",
					"2",
					"3",
					"4",
					"5",
					"6",
					"7",
					"8",
					"9",
				},
				DefaultValue = 3,
				SortPriority = 1,
			},
			
			{
				Name = "Rift grain",
				Values = 
				{
					"0",
					"1",
					"2",
					"3",
				},
				DefaultValue = 1,
				SortPriority = 2,
			},

			{
				Name = "Invert heights",
				Values = 
				{
					"False",
					"True",
				},
				DefaultValue = 1,
				SortPriority = 3,
			},
			
			{
				Name = "Polar",
				Values = 
				{
					"False",
					"True",
				},
				DefaultValue = 2,
				SortPriority = 4,
			},
			
			{
				Name = "Water, percent",
				Values = 
				{
					"10",
					"20",
					"30",
					"40",
					"50",
					"60",
					"70",
					"80",
					"90",
				},
				DefaultValue = 7,
				SortPriority = 5,
			},
			
			{
				Name = "Hills and peaks adjustment",
				Values = 
				{
					"0",
					"1",
					"2",
					"3",
					"4",
					"5",
					"6",
					"7",
					"8",
					"9",
				},
				DefaultValue = 4,
				SortPriority = 6,
			},
			
			{
				Name = "Extra mountains",
				Values = 
				{
					"0",
					"1",
					"2",
					"3",
					"4",
					"5",
					"6",
					"7",
					"8",
					"9",
				},
				DefaultValue = 1,
				SortPriority = 7,
			},
			{
				Name = "Adjust plates, times",
				Values = 
				{
					"0.25",
					"0.50",
					"0.75",
					"1.0",
					"1.25",
					"1.50",
					"1.75",
					"2.00",
				},
				DefaultValue = 4,
				SortPriority = 8,
			},

			{
				Name = "Shift plot types",
				Values = 
				{
					"False",
					"True",
				},
				DefaultValue = 1,
				SortPriority = 9,
			},

			{
				Name = "Tectonic islands",
				Values = 
				{
					"False",
					"True",
				},
				DefaultValue = 1,
				SortPriority = 10,
			},
			
			{
				Name = "Has centre rift",
				Values = 
				{
					"False",
					"True",
				},
				DefaultValue = 1,
				SortPriority = 11,
			},
			
			--hills_ridge_flags = args.hills_ridge_flags or self.iFlags;
			--peaks_ridge_flags = args.peaks_ridge_flags or self.iFlags;
			}
	}
end
------------------------------------------------------------------------------

------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types ...");

	local fractal_world = FractalWorld.Create();
	
	local cg = Map.GetCustomOption(1);
	local rg = Map.GetCustomOption(2) - 1; -- Default no rifts. Set grain to between 1 and 3 to add rifts. - Bob
	local ih = Map.GetCustomOption(3) == 2;
	local plr = Map.GetCustomOption(4) == 2;
	--local ridge_flags = args.ridge_flags or self.iFlags;
	print("continent_grain", cg)
	print("rift_grain", rg)
	print("invert_heights", ih)
	print("polar", plr)
	
	fractal_world:InitFractal{continent_grain = cg, rift_grain = rg, invert_heights = ih, polar = plr};
	
	
	local args = {};
	args.sea_level = 2; -- Default is Medium sea level.
	args.world_age = 2; -- Default is 4 Billion Years old.
	
	args.sea_level_normal = Map.GetCustomOption(5) * 10;
	args.world_age_normal = Map.GetCustomOption(6) - 1;
	args.extra_mountains = Map.GetCustomOption(7) - 1;
	args.adjust_plates = Map.GetCustomOption(8) / 4;
	args.shift_plot_types = Map.GetCustomOption(9) == 2;
	args.tectonic_islands = Map.GetCustomOption(10) == 2;
	--args.hills_ridge_flags = self.iFlags;
	--args.peaks_ridge_flags = self.iFlags;
	args.has_center_rift = Map.GetCustomOption(11) == 2;
	
	for key,value in pairs(args) do print(key,value) end

	local plotTypes = fractal_world:GeneratePlotTypes(args);
	
	SetPlotTypes(plotTypes);
	
	local args = {expansion_diceroll_table = {10, 4, 4}};
	GenerateCoasts(args);
end
------------------------------------------------------------------------------
function GenerateTerrain()
	print("Generating Terrain ...");
	

	local args = 
	{
	};
	local terraingen = TerrainGenerator.Create(args);

	terrainTypes = terraingen:GenerateTerrain();
	
	SetTerrainTypes(terrainTypes);
end
------------------------------------------------------------------------------
function AddFeatures()
	print("Adding Features ...");
	
	local args = 
	{
	}
	local featuregen = FeatureGenerator.Create(args);

	-- False parameter removes mountains from coastlines.
	featuregen:AddFeatures(false);
end
------------------------------------------------------------------------------
function StartPlotSystem()
	print("Creating start plot database.");
	local start_plot_database = AssignStartingPlots.Create()
	
	print("Dividing the map in to Regions.");
	-- Regional Division Method 3: Rectangular Division
	local args = 
	{
		method = 3
	};
	
	start_plot_database:GenerateRegions(args)

	print("Choosing start locations for civilizations.");
	-- Forcing starts along the ocean.
	-- Lowering start position minimum eligibility thresholds.
	local args = 
	{
		mustBeCoast = true,
		minFoodMiddle = 2,
		minProdMiddle = 1,
		minFoodOuter = 2,
		minProdOuter = 1
	};
	start_plot_database:ChooseLocations(args)
	
	print("Normalizing start locations and assigning them to Players.");
	start_plot_database:BalanceAndAssign()

	print("Placing Natural Wonders.");
	start_plot_database:PlaceNaturalWonders()

	print("Placing Resources and City States.");
	start_plot_database:PlaceResourcesAndCityStates()
	
	-- tell the AI that we should treat this as a naval + offshore expansion map
	Map.ChangeAIMapHint(1+4);

end
------------------------------------------------------------------------------
