package;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.math.RandGenerator;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.HeapsSimpleView;
import h2d.Graphics;
import hxd.Res;
import h2d.Interactive;
import hxd.Event;
class Pathfinding extends hxd.App {
    var _mesh : Mesh;
    var _view : HeapsSimpleView;
    var _entityAI : EntityAI;
    var _pathfinder : PathFinder;
    var _path : Array<Float>;
    var _pathSampler : LinearPathSampler;
    var _newPath:Bool = false;
    var x: Float = 0;
    var y: Float = 0;
    var g:          Graphics; 
    var bg:         Interactive;
    override function init() {
        // Initialize all loaders for embeded resources
        // Res.initEmbed(); // required for font add one to the res folder
        bg = new Interactive(600, 600, s2d );
        bg.onPush       = function( e ){ onMouseDown( e.button, e.relX, e.relY ); };
        bg.onRelease    = function( e ){ onMouseUp(   e.button, e.relX, e.relY ); };
        bg.onMove       = function( e ){ onMouseMove( e.relX, e.relY ); };
        bg.backgroundColor = 0xffcccccc;
        g = new Graphics( s2d );
        _view = new HeapsSimpleView();
        // build a rectangular 2 polygons mesh of 600x600
        _mesh = RectMesh.buildRectangle(600, 600);
        // create viewports
        _view = new HeapsSimpleView();
        // pseudo random generator
        var randGen : RandGenerator;
        randGen = new RandGenerator();
        randGen.seed = 7259;  // put a 4 digits number here
        // populate mesh with many square objects
        var object : Object;
        var shapeCoords : Array<Float>;
        for (i in 0...50){
            object = new Object();
            shapeCoords = new Array<Float>();
            shapeCoords = [ -1, -1, 1, -1,
                             1, -1, 1, 1,
                            1, 1, -1, 1,
                            -1, 1, -1, -1];
            object.coordinates = shapeCoords;
            randGen.rangeMin = 10;
            randGen.rangeMax = 40;
            object.scaleX = randGen.next();
            object.scaleY = randGen.next();
            randGen.rangeMin = 0;
            randGen.rangeMax = 1000;
            object.rotation = (randGen.next() / 1000) * Math.PI / 2;
            randGen.rangeMin = 50;
            randGen.rangeMax = 600;
            object.x = randGen.next();
            object.y = randGen.next();
            _mesh.insertObject(object);
        }
        // we need an entity
        _entityAI = new EntityAI();
        // set radius as size for your entity
        _entityAI.radius = 4;
        // set a position
        _entityAI.x = 20;
        _entityAI.y = 20;
        // now configure the pathfinder
        _pathfinder = new PathFinder();
        _pathfinder.entity = _entityAI;  // set the entity
        _pathfinder.mesh = _mesh;  // set the mesh
        // we need a vector to store the path
        _path = new Array<Float>();
        // then configure the path sampler
        _pathSampler = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = 10;
        _pathSampler.path = _path;
    }
    public function onMouseDown( button: Int, x_: Float, y_: Float ): Void {
        if( button == 0 ){
            x = x_;
            y = y_;
            _newPath = true;
        }
    }
    public function onMouseUp( button: Int, x_: Float, y_: Float ): Void {
        if( button == 0 ){
            x = x_;
            y = y_;
            _newPath = false;
        }
    }
    public function onMouseMove( x_: Float, y_: Float ): Void {
        if( _newPath ){
            x = x_;
            y = y_;
        }
    }
    inline function renderDaedalus( g2: Graphics ){
        // show result mesh on screen
        _view.drawMesh( g2, _mesh );
        if( _newPath ){
            // find path !
            _pathfinder.findPath( x, y, _path );
            // show path on screen
            _view.drawPath( g2, _path );
             // show entity position on screen
            _view.drawEntity( g2, _entityAI ); 
            // reset the path sampler to manage new generated path
            _pathSampler.reset();
        }
        // animate !
        if ( _pathSampler.hasNext ) {
            // move entity
            _pathSampler.next();
        }
        // show entity position on screen
        _view.drawEntity( g2, _entityAI );
    }
    override function update(dt:Float) {
        g.clear();
        renderDaedalus( g );
    }
    static function main() {
        new Pathfinding();
    }
}