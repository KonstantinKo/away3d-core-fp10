﻿package away3d.exporters{	import away3d.events.*;		import away3d.arcane;	import away3d.animators.utils.*;	import away3d.containers.*;	import away3d.core.base.*;		import flash.events.*;	import flash.geom.*;		use namespace arcane;		/**	* Class AC3DExporter generates a string in the AC3D .ac format representing the object3D(s).	* Export version format 11. hex b	*/	public class AC3DExporter extends EventDispatcher	{		private var acString:String = "";		private var _scaling:Number;		private var _nRotation:Vector3D = new Vector3D();		private var _cr:String;				private  function getIndexV(verts:Vector.<Vertex>, v:Vertex):int		{			var index:int;						for(var i:int = 0; i<verts.length; ++i){				if(v.x == verts[i].x && v.y == verts[i].y && v.z == verts[i].z)					return i;			}						return 0;		}					private  function write(object3d:Mesh):void		{			var aV:Array = [];			var aVn:Array = [];			var aVt:Array = [];			var aF:Array = [];					acString += "OBJECT poly"+_cr;			acString += "name \""+object3d.name+"\""+_cr;			acString += "loc "+object3d.position.x*_scaling+" "+object3d.position.y*_scaling+" "+object3d.position.z*_scaling+_cr;			//no embeds possible from Away3D Flash API. Check AIR package in svn			//acString += "texture \"\"\n";			acString += "crease 45.000000"+_cr;			var vertCount:int = object3d.vertices.length;			acString += "numvert "+vertCount+_cr;						var v:Vertex;			var tmp:Vector3D = new Vector3D();						_nRotation.x = object3d.rotationX;			_nRotation.y = object3d.rotationY;			_nRotation.z = object3d.rotationZ;						for(var i:int = 0; i<vertCount; ++i){				v = object3d.vertices[i];				 				tmp.x =  v.x *_scaling;				tmp.y =  v.y *_scaling;				tmp.z =  v.z *_scaling;				tmp = PathUtils.rotatePoint(tmp, _nRotation);									acString += -tmp.x+" "+tmp.y+" "+tmp.z+_cr;			}						var aFaces:Vector.<Face> = object3d.faces;			var faceCount:int = aFaces.length;			var f:Face;			 			acString += "numsurf "+faceCount+_cr;						for(i = 0; i<faceCount;++i)			{				acString += "SURF 0x30\nmat 0\nrefs 3"+_cr;				f = aFaces[i];								acString += getIndexV(object3d.vertices, f.v0)+" "+f.uv0.u+" "+f.uv0.v+_cr;				acString += getIndexV(object3d.vertices, f.v1)+" "+f.uv1.u+" "+f.uv1.v+_cr;				acString += getIndexV(object3d.vertices, f.v2)+" "+f.uv2.u+" "+f.uv2.v+_cr;			}						acString += "kids 0"+_cr;		}				private  function parse(object3d:Object3D):void		{			if(object3d is ObjectContainer3D){							var obj:ObjectContainer3D = (object3d as ObjectContainer3D);								if(obj.children.length != 0){					acString += "OBJECT group"+_cr;					acString += "name \""+obj.name+"\""+_cr;					acString += "kids "+obj.children.length+_cr;				}								for(var i:int =0;i<obj.children.length;++i){					if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i]);					} else if(obj.children[i] is Mesh){						write( obj.children[i] as Mesh);					}				}						} else if (object3d is Mesh) {				write( object3d as Mesh);			}		}		/**		* AC3DExporter generates a string in the AC3D .ac format representing the object3D(s).		*/		function AC3DExporter(){}				/**		* Generates a string in the AC3D .ac format representing the object3D(s). Export version format 11. hex b		* The event onComplete, returns in event.data the generated string.		*		* @param	object3d				Object3D. The Object3D to be exported to AC3D .ac format.		* @param	scaling					[optional] Number. if the model output needs to be resized. Default = 1.		*		* IMPORTANT: A little missing feature into AC3D parser doesn't support regular line returns as shown in trace panel.		* And the Trace class or trace panel textfield doesn't respect the returns char values as they are defined during the string construction.		* Here's what you need to add to your code in order to trace a valid file for AC3D:		*		* This example shows how to export a cube to ac3d.		private function export():void 		{			ACExporter = new AC3DExporter();			ACExporter.addOnExportComplete(onExportDone);			var cube:Cube = new Cube({width:10, height:10, depth:10});			_scene.addChild(cube);			ACExporter.export(cube, 1);		}				private function onExportDone(e:ExporterEvent):void 		{			//trace(e.data); // do not use the trace panel as you would do for ObjExporter.			//Wrong returns char set. as a result AC3D fails to parse the file			trace("please press once on screen");			stage.addEventListener(MouseEvent.CLICK, setToClipboard);		}		private function setToClipboard(e:MouseEvent):void 		{			stage.removeEventListener(MouseEvent.CLICK,setToClipboard);			System.setClipboard(ACExporter.acFile);						trace("paste into a text editor and save as 'myfile.ac'");		}		*/		public function export(object3d:Object3D, scaling:Number = 1):void		{						if(hasEventListener(ExporterEvent.COMPLETE)){				_cr = String.fromCharCode(10);				acString = "AC3Db"+_cr+"MATERIAL \"ac3dmat1\"";				acString += " rgb 1 1 1  amb 0.2 0.2 0.2  emis 0 0 0  spec 0.2 0.2 0.2  shi 128  trans 0"+_cr;				acString += "OBJECT world"+_cr;				_scaling = scaling;				parse(object3d);								var EE:ExporterEvent = new ExporterEvent(ExporterEvent.COMPLETE);				EE.data = acString;				dispatchEvent(EE);							} else {				trace("No ExporterEvent.COMPLETE event set. Use the method addOnExportComplete(myfunction) before use export();");			}		}				/**		 * Default method for adding a complete event listener		 * The event.data holds the generated string (ac file string) from the AC3DExporter class		 * 		 * @param	listener		The listener function		 */		public function addOnExportComplete(listener:Function):void        {			addEventListener(ExporterEvent.COMPLETE, listener, false, 0, false);        }		/**		 * Default method for removing a complete event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnExportComplete(listener:Function):void        {            removeEventListener(ExporterEvent.COMPLETE, listener, false);        }		/**		 * Returns the last generated ac file string async from events.		 */		public function get acFile():String		{			return acString;		}		 	}}