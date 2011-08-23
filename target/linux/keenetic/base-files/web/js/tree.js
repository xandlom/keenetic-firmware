function Folder(folderDescription, hreference) //constructor 
{ 
  //constant data
  this.desc = folderDescription
  this.hreference = hreference
  this.id = -1
  this.navObj = 0
  this.iconImg = 0
  this.nodeImg = 0
  this.isLastNode = 0
  //dynamic data
  this.isOpen = true
  this.children = new Array
  this.nChildren = 0
  //methods
  this.initialize = initializeFolder
  this.setState = setStateFolder
  this.addChild = addChild
  this.createIndex = createEntryIndex
  this.hide = hideFolder
  this.display = display
  this.renderOb = drawFolder
  this.totalHeight = totalHeight
  this.subEntries = folderSubEntries
  this.outputLink = outputFolderLink
}
function setStateFolder(isOpen) 
{
  var subEntries
  var totalHeight
  var fIt = 0
  var i=0

  if (isOpen == this.isOpen)
    return
 
if (browserVersion == 2)
{
    totalHeight = 0
    for (i=0; i < this.nChildren; i++)
      totalHeight = totalHeight + this.children[i].navObj.clip.height
      subEntries = this.subEntries()
    if (this.isOpen)
      totalHeight = 0 - totalHeight
    for (fIt = this.id + subEntries + 1; fIt < nEntries; fIt++)
      indexOfEntries[fIt].navObj.moveBy(0, totalHeight)
}
  this.isOpen = isOpen
  propagateChangesInState(this)
}
 
function propagateChangesInState(folder)
{
	var i=0
	if (folder.isOpen){ 
	if (folder.nodeImg) 
	if (folder.isLastNode ) 
	folder.nodeImg.src = "i/ftv2mlastnode.gif" 
	else 
	    folder.nodeImg.src = "i/ftv2mnode.gif" 
	for (i=0; i<folder.nChildren; i++)
	folder.children[i].display() 
	} else { 
	if (folder.nodeImg) 
	if (folder.isLastNode) 
	folder.nodeImg.src = "i/ftv2plastnode.gif" 
	else 
	    folder.nodeImg.src = "i/ftv2pnode.gif" 
	for (i=0; i<folder.nChildren; i++) 
	folder.children[i].hide() 
	}  
} 
 
function hideFolder() 
{ 
	if (browserVersion == 1 || browserVersion == 3) { 
		if (this.navObj.style.display == "none") 
		return 
		this.navObj.style.display = "none" 
	} else { 
		if (this.navObj.visibility == "hiden") 
		return 
		this.navObj.visibility = "hiden" 
	} 
	
	this.setState(0) 
} 
 
function initializeFolder(level, lastNode, leftSide) 
{ 
var j=0 
var i=0 
var numberOfFolders 
var numberOfDocs 
var nc 
      
  nc = this.nChildren 
   
  this.createIndex() 
 
  var auxEv = "" 
 
  if (browserVersion > 0) 
    auxEv = "<a href='javascript:clickOnNode("+this.id+")'>" 
  else 
    auxEv = "<a>" 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' id='nodeIcon" + this.id + "' src='i/ftv2mlastnode.gif' width='16px' height='22px' border='0'></a>") 
      leftSide = leftSide + "<img src='i/tblank.gif' width='16px' height='22px'>"  
      this.isLastNode = 1 
    } 
    else 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' id='nodeIcon" + this.id + "' src='i/ftv2mnode.gif' width='16px' height='22px' border='0'></a>") 
      leftSide = leftSide + "<img src='i/ftv2vertline.gif' width='16px' height='22px'>" 
      this.isLastNode = 0 
    } 
  else 
    this.renderOb("") 
   
  if (nc > 0) 
  { 
    level = level + 1 
    for (i=0 ; i < this.nChildren; i++)  
    { 
      if (i == this.nChildren-1) 
        this.children[i].initialize(level, 1, leftSide) 
      else 
        this.children[i].initialize(level, 0, leftSide) 
      } 
  } 
} 
 
function drawFolder(leftSide) 
{ 
  if (browserVersion == 2) { 
    if (!doc.yPos) 
      doc.yPos=8 
    doc.write("<layer id='folder" + this.id + "' top=" + doc.yPos + " visibility='hidden'>") 
  }
   
  doc.write("<table ") 
  if (browserVersion == 1 || browserVersion == 3) 
    doc.write(" id='folder" + this.id + "' style='position:relative;' ") 
  doc.write(" border='0' cellspacing='0' cellpadding='0'>") 
  doc.write("<tr><td>") 
  doc.write(leftSide) 
  this.outputLink() 
  doc.write("</td><td valign='middle' nowrap='nowrap'>") 
  if (USETEXTLINKS) 
  { 
    this.outputLink() 
    doc.write(this.desc + "</a>") 
  } 
  else 
    doc.write(this.desc) 
  doc.write("</td>")  
  doc.write("</table>") 
   
  if (browserVersion == 2) { 
    doc.write("</layer>") 
  } 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["folder"+this.id] 
    this.nodeImg = doc.all["nodeIcon"+this.id] 
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["folder"+this.id] 
    this.nodeImg = this.navObj.document.images["nodeIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } else if (browserVersion == 3) { 
    this.navObj = doc.getElementById("folder"+this.id)
    this.nodeImg = doc.getElementById("nodeIcon"+this.id) 
  }
} 
 
function outputFolderLink() 
{ 
  if (this.hreference) 
  { 
    doc.write("<a href='" + this.hreference + "' TARGET=\"view\" ") 
    if (browserVersion > 0) 
      doc.write("onClick='javascript:clickOnFolder("+this.id+")'") 
    doc.write(">") 
  } 
  else 
    doc.write("<a>") 
  if (this.id != 0)
  	doc.write("<a href='javascript:clickOnFolder("+this.id+")' style='text-decoration:none'>")   
} 
 
function addChild(childNode) 
{ 
  this.children[this.nChildren] = childNode 
  childNode.parentObj = this
  this.nChildren++ 
  return childNode 
} 
 
function folderSubEntries() 
{ 
  var i = 0 
  var se = this.nChildren 
 
  for (i=0; i < this.nChildren; i++){ 
    if (this.children[i].children) //is a folder 
      se = se + this.children[i].subEntries() 
  } 
 
  return se 
} 
 
// Definition of class Item (a document or link inside a Folder) 
function Item(itemDescription, itemLink) // Constructor 
{ 
  // constant data 
  this.desc = itemDescription 
  this.link = itemLink 
  this.id = -1  
  this.navObj = 0  
  this.iconImg = 0
 
  // methods 
  this.initialize = initializeItem 
  this.createIndex = createEntryIndex 
  this.hide = hideItem 
  this.display = display 
  this.renderOb = drawItem 
  this.totalHeight = totalHeight 
} 
 
function hideItem() 
{ 
  if (browserVersion == 1 || browserVersion == 3) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  }     
} 
 
function initializeItem(level, lastNode, leftSide) 
{  
  this.createIndex() 
 
  if (level>0) 
    if (lastNode) 
    { 
      this.renderOb(leftSide + "<img src='i/ftv2joinbottom.gif' width='16px' height='22px'>")
      leftSide = leftSide + "<img src='i/tblank.gif' width='16px' height='22px'>"  
    } 
    else 
    { 
      this.renderOb(leftSide + "<img src='i/ftv2join.gif' width='16px' height='22px'>")
      leftSide = leftSide + "<img src='i/ftv2vertline.gif' width='16px' height='22px'>" 
    } 
  else 
    this.renderOb("")   
} 
 
function drawItem(leftSide) 
{ 
  if (browserVersion == 2) 
    doc.write("<layer id='item" + this.id + "' top=" + doc.yPos + " visibility='hidden'>") 
     
  doc.write("<table ") 
  if (browserVersion == 1 || browserVersion == 3) 
    doc.write(" id='item" + this.id + "' style='position:relative;' ") 
  doc.write(" border='0' cellspacing='0' cellpadding='0'>") 
  doc.write("<tr><td>") 
  doc.write(leftSide) 
  doc.write("</td><td valign='middle' nowrap='nowrap'>") 
  if (USETEXTLINKS) 
    doc.write("<a href=" + this.link + "style='text-decoration:none'>" + this.desc + "</a>"); 
  else 
    doc.write(this.desc); 
  doc.write("</table>"); 
   
  if (browserVersion == 2) 
    doc.write("</layer>"); 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["item"+this.id];
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["item"+this.id]; 
    doc.yPos=doc.yPos+this.navObj.clip.height;
  }  else if (browserVersion == 3) { 
    this.navObj = doc.getElementById("item"+this.id); 
  }
} 
// Methods common to both objects (pseudo-inheritance) 
function display() 
{ 
  if (browserVersion == 1 || browserVersion == 3) 
    this.navObj.style.display = "block"; 
  else 
    this.navObj.visibility = "show"; 
} 
 
function createEntryIndex() 
{ 
  this.id = nEntries 
  indexOfEntries[nEntries] = this 
  nEntries++ 
} 
 
// total height of subEntries open 
function totalHeight() //used with browserVersion == 2 
{ 
  var h = this.navObj.clip.height 
  var i = 0 

  if (this.isOpen) //is a folder and _is_ open 
    for (i=0 ; i < this.nChildren; i++)  
      h = h + this.children[i].totalHeight() 
  return h 
} 
 
 
// Events 
function clickOnFolder(folderId) 
{ 
  var clicked = indexOfEntries[folderId] 
  if (folderId != 0)
  	clickOnNode(folderId) 
} 
 
function clickOnNode(folderId) 
{ 
	var clickedFolder = indexOfEntries[folderId],
	    isOpen = clickedFolder.isOpen;

	if (!isOpen) {
		var idx, root_folder = indexOfEntries[0].children;
		for (idx = 0; idx < root_folder.length; ++idx)
			if (folderId == root_folder[idx].id) {
				for (idx = 0; idx < root_folder.length; ++idx) {
					var entry = root_folder[idx];
					if (entry.id != folderId) {
						if (entry.isOpen)
							entry.setState(0);
					}
				}
				break;
			}
	}

	clickedFolder.setState(!isOpen) //open<->close  
}
 
function initializeDocument() 
{ 
  if (doc.all) 
    browserVersion = 1 //IE > 4   
  else 
    if (doc.layers) 
      browserVersion = 2 //NS 4 .x
    else 
	 if (doc.getElementById)
      browserVersion = 3 //NS 6.x
	else
	  browserVersion = 0
 
  foldersTree.initialize(0, 1, "") 
  foldersTree.display()
  
  if (browserVersion > 0) 
  { 
    doc.write("<layer top="+indexOfEntries[nEntries-1].navObj.top+">&nbsp;</layer>") 
    // close the whole tree 
    clickOnNode(0) 
    // open the root folder 
    clickOnNode(0) 
  } 
} 
 
// Auxiliary Functions for Folder-Treee backward compatibility 
function gFld(description, hreference) 
{ 
  return new Folder(description, hreference)
} 
 
function gLnk(target, description, linkData, title) 
{ 
  var fullLink = "" 

  if (target==0) 
  { 
    fullLink = "'"+linkData+"' target=\"view\"" 
  } 
  else 
  { 
    if (target==1) 
       fullLink = "'http://"+linkData+"' target='_blank'" 
    else
    {
    if (target==2) 
   		 fullLink = "'"+linkData+"' target=\"_blank\"" 
    else
	  { 
       if (target==3) 
	   {
       fullLink = "'"+linkData+"' target=\"_top\"" 
	   }
	   else
	   {
       fullLink = "'http://"+linkData+"' target=\"view\"" 
	   }
	  }
    }
  } 

  return new Item(description, fullLink)
} 
 
function insFld(parentFolder, childFolder)
{ 
  return parentFolder.addChild(childFolder) 
} 

function insDoc(parentFolder, document) 
{ 
  return parentFolder.addChild(document) 
}
// Global variables  
var USETEXTLINKS = 1
var indexOfEntries = new Array 
var nEntries = 0 
var doc = document 
var browserVersion = 0 
var selectedFolder = 0
