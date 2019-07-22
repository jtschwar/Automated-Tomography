//Step 1 Code: Get 3 images (manually setting), gather their coordinates, export info to textfile
//WIP, ask Jacob if any questions on functionality

//TO-DO:
//Directory Define (Where do we want it to go? Should we allow user choice?)
//Add angles to output text

number image1x,image1y,image1z
number image2x,image2y,image2z
number image3x,image3y,image3z
number placeholder1, placeholder2
string file_name = "GenericNarme.txt"

class MainMenu : uiframe
{

	TagGroup ButtonCreate(object self)
	{
		TagGroup image1Button = DLGCreatePushButton("Acquire Image 1 (0 degrees)", "image1")
		TagGroup image2Button = DLGCreatePushButton("Acquire Image 2 (- degrees)", "image2")
		TagGroup image3Button = DLGCreatePushButton("Acquire Image 1 (+ degrees)", "image3")
		TagGroup ImageButtonGroup = DLGgroupitems(image1Button, image2Button, image3button).dlgTableLayout(3,1,0)
		
		TagGroup ExportButton = DLGCreatePushButton("Export Positions", "Export").dlgexternalpadding(10,10)
		
		TagGroup FinalButtonGroup = DLGgroupitems(ImagebuttonGroup, ExportButton)
		return FinalButtonGroup
	}

	object Launch(object self)
	{
		self.init(self.ButtonCreate())
		self.Pose()
	}
	
	void image1(object self)
	{
		//EMGetStagePositions(7,image1x,image1y,image1z,placeholder1,placeholder2)
	}
	
	void image2(object self)
	{
		//EMGetStagePositions(7,image2x,image2y,image2z,placeholder1,placeholder2)
	}
	
	void image3(object self)
	{
		//EMGetStagePositions(7,image3x,image3y,image3z,placeholder1,placeholder2)
	}
	
	void Export(object self)
	{
		image1x = 10
		string output1 = image1x + " " + image1y + " " + image1z + "\n" 
		string output2 = image2x + " " + image2y + " " + image2z + "\n" 
		string output3 = image3x + " " + image3y + " " + image3z + "\n" 
		string finaloutput = output1 + output2 + output3
		number file = CreateFileForWriting(file_name )
		WriteFile(file, finaloutput)
		CloseFile(file)
	}

}

void CreateDialog()
{
	alloc(MainMenu).Launch()
}

CreateDialog()