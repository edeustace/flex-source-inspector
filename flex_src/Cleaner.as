package com.allurent.cleaner.model.domain
{
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	public class Cleaner
	{
		
		[Bindable]
		public var moveDirectory : File;
		
		[Bindable]
		public var actionscriptProperties : ActionscriptProperties;
		
		[Bindable] 
		public var unusedClasses : ArrayCollection;
		
		[Bindable]
		public var movedFiles : ArrayCollection = new ArrayCollection(); 
		
		[Bindable]		
		public var foldersToIgnore : ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var scanComplete : Boolean;
		
		[Bindable]
		public var cleanComplete : Boolean;
		
		[Bindable]
		public var scanFoundUnusedClasses : Boolean;
		
		
		private var srcFiles : ArrayCollection = new ArrayCollection();
		private var reportUsedClasses : ArrayCollection = new ArrayCollection();
		private var pendingListings : int = 0; 
		private var flexProject : FlexProjectFolder;
		
		public function Cleaner()
		{
		}
		
		public function clean() : void
		{
			movedFiles = new ArrayCollection();
			
			for( var i : int = 0 ; i < unusedClasses.length ; i++ )
			{
				
				var unusedClass : UnusedClass = unusedClasses.getItemAt( i ) as UnusedClass;
				
				if( unusedClass.markedForRemoval )
				{
					moveFile( unusedClass.file );		
				}
			}
			
			cleanComplete = true;
		}
		
		public function moveLocationChosen( directory : File ) : void
		{
			moveDirectory = directory;
		}
		
		public function manuallyAddApplication( file : File ) : void
        {
        	if( actionscriptProperties == null )
        	{
        		return;
        	}
        	
        	actionscriptProperties.addApplication( file );
        }  
        
        public function beginSearching() : void
		{
			pendingListings += 1;
			
			var sourceFolder : File = projectFolder.resolvePath( actionscriptProperties.sourceFolderPath );
			
			sourceFolder.addEventListener( FileListEvent.DIRECTORY_LISTING, 
			                      handleDirectoryListing );
			sourceFolder.getDirectoryListingAsync();
		}
		
		public function markAllUnusedClassesForRemoval() : void
		{
			markAllUnusedClasses( true );
		}
		
		public function unMarkAllUnusedClassesForRemoval() : void
		{
			markAllUnusedClasses( false );
		}
		
		private function handleDirectoryListing( event:FileListEvent ) : void
		{
			pendingListings -= 1;
		   			
		    for each ( var item:File in event.files )
		    {
		    	if( item.isDirectory )
		    	{
		    		item.getDirectoryListingAsync();
		    		pendingListings += 1;
		    		
		    		item.addEventListener( FileListEvent.DIRECTORY_LISTING, 
			                      handleDirectoryListing );
		    	}
		    	else if( item.extension == "mxml" || item.extension == "as" )
		    	{
		    		srcFiles.addItem( item );
		    	}
		    }
		    
		    if( pendingListings == 0 )
		    {
				
		    	checkForUnusedClasses();
		    }
		}
	
		
		private function populateUnusedClasses() : void
		{
			unusedClasses = new ArrayCollection();
			
			for( var i : int = 0; i < srcFiles.length ; i++ )
			{
				
				var classFile : File = srcFiles.getItemAt(i) as File;
				
				if( !reportUsedClasses.contains( classFile.nativePath )
					&& 
					!actionscriptProperties.isPartOfApplicationClassPath( classFile ) 
					&&
					!isWithinAnIgnoredFolder( classFile ) )
				{
					//trace( "! class: " + classFile.name + " not in the report.. adding" );
					unusedClasses.addItem( new UnusedClass( classFile ) );
				}
				else
				{
					//trace( "> class: " + classFile.name + " is in the report" );
				}
			}
			
			scanComplete = true;
			scanFoundUnusedClasses = unusedClasses.length > 0;
		}
		
		private function isWithinAnIgnoredFolder( classFile : File ) : Boolean
		{
			for( var i : int = 0 ; i < foldersToIgnore.length ; i++ )
			{
				var folder : File = foldersToIgnore.getItemAt( i ) as File;
				
				var relativePath : String = folder.getRelativePath( classFile );
				
				if( relativePath != null )
				{
					return true;
				}
			}
			return false;
		}
		
		
		private function checkForUnusedClasses() : void
		{
			unusedClasses = new ArrayCollection();
			reportUsedClasses = new ArrayCollection();
			
			for( var i : int = 0 ; i < actionscriptProperties.applications.length; i++ )
			{
				var flexModel : FlexApplication = actionscriptProperties.applications.getItemAt( i ) as FlexApplication;
				
				if( !flexModel.ignore )
				{
					addUsedClassesFromReport( flexModel.linkReport, reportUsedClasses );	
				}
			}
			
			populateUnusedClasses();
		}
		
		private function addUsedClassesFromReport( reportFile : File, classCollection : ArrayCollection ) : void
		{
			var stream:FileStream = new FileStream();
			stream.open( reportFile, FileMode.READ );
			var contents:String = stream.readUTFBytes( stream.bytesAvailable )
			var linkReportXML : XML = new XML( contents );
			
			for each( var scriptNode :  XML in linkReportXML..script )
			{
				var name : String = scriptNode.@name.toString();
				var sourcePath : String = projectFolder.nativePath + File.separator + actionscriptProperties.sourceFolderPath;
				if( name.indexOf( sourcePath ) != -1 )
				{
					var className : String = scriptNode.@name.toString();
					trace("adding to used classes: " + className );
					if( !classCollection.contains( className ) )
					{
						classCollection.addItem( className );
					}
				}
			}
		
		}
		
		private function markAllUnusedClasses( forRemoval : Boolean ) : void
		{
			for( var i : int = 0 ; i < unusedClasses.length ; i++ )
			{
				var unusedClass : UnusedClass = unusedClasses.getItemAt( i ) as UnusedClass;
				unusedClass.markedForRemoval = forRemoval;
			}
		}
		
	
		public function addFolderToIgnore( folder : File ) : void
		{
			if( !foldersToIgnore.contains( folder ) )
			{
				foldersToIgnore.addItem( folder );	
			}
		}
		
		private function moveFile( fileToMove : File ) : void
		{
			var newPath : String = fileToMove.nativePath.replace( projectFolder.nativePath + File.separator + actionscriptProperties.sourceFolderPath + File.separator, "" );
			var newFile : File = moveDirectory.resolvePath( newPath );
			fileToMove.moveTo( newFile, true );
			
			movedFiles.addItem( newFile );
		}
		

		public function set projectFolder( value  : File ) : void
		{
			if( value == null )
			{
				flexProject = null;
				actionscriptProperties = null;
				return;
			}
			
			flexProject = new FlexProjectFolder( value );
			actionscriptProperties = new ActionscriptProperties( flexProject.getASPropertiesFile() );
		}
		
		[Bindable]
		public function get projectFolder() : File
		{
			return flexProject == null ? null : flexProject.getFolder();
		}
		
		
	}
}