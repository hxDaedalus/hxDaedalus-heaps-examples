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
import hxd.Key in K;

class PathfindingMaze extends hxd.App {
    var _mesh : Mesh;
    var _view : HeapsSimpleView;
    var _entityAI : EntityAI;
    var _pathfinder : PathFinder;
    var _path : Array<Float>;
    var _pathSampler : LinearPathSampler;
    var _newPath:Bool = false;
    var x: Float = 0;
    var y: Float = 0;
    var rows: Int = 15;
    var cols: Int = 15;
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
        
        var object : Object;
        GridMaze.generate(600, 600, cols, rows);
        _mesh.insertObject(GridMaze.object);
        _view.constraintsWidth = 4;
        // we need an entity
        _entityAI = new EntityAI();
        // set radius as size for your entity
        _entityAI.radius = GridMaze.tileWidth * .3;
        // set a position
        _entityAI.x = GridMaze.tileWidth / 2;
        _entityAI.y = GridMaze.tileHeight / 2;
        // now configure the pathfinder
        _pathfinder = new PathFinder();
        _pathfinder.entity = _entityAI;  // set the entity
        _pathfinder.mesh = _mesh;  // set the mesh
        // we need a vector to store the path
        _path = new Array<Float>();
        // then configure the path sampler
        _pathSampler = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = GridMaze.tileWidth * .7;
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
    function reset(newMaze:Bool = false):Void {
        var seed = Std.int(Math.random() * 10000 + 1000);
        if( newMaze ) {
            _mesh = RectMesh.buildRectangle(600, 600);
            GridMaze.generate(600, 600, 30, 30, seed);
            GridMaze.object.scaleX = .92;
            GridMaze.object.scaleY = .92;
            GridMaze.object.x = 23;
            GridMaze.object.y = 23;
            _mesh.insertObject(GridMaze.object);
        }
        _entityAI.radius = GridMaze.tileWidth * .27;
        _pathSampler.samplingDistance = GridMaze.tileWidth * .7;
        _pathfinder.mesh = _mesh;
        _entityAI.x = GridMaze.tileWidth / 2;
        _entityAI.y = GridMaze.tileHeight / 2;
        _path = [];
        _pathSampler.path = _path;
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
        if( K.isDown( K.SPACE ) ) reset( true );
        g.clear();
        renderDaedalus( g );
    }
    static function main() {
        new PathfindingMaze();
    }
}