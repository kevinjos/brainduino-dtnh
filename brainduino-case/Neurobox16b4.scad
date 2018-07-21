/* [Credits] */
// www.brain-duino.com
// License CC-BY-SA 4.0
// Silver Kuusik - silver.kuusik@gmail.com

// Big thanks to:
// FB Aka Heartman/Hearty 2016
// http://www.thingiverse.com/thing:1264391

// Big thanks to:
// R. Miloh Alexander
// froggytoad@gmail.com

// Big thanks to:
// beau@nubcore.com
// 3D printing


/* [Version info] */
Version = "Neurobox v1.6.3.s";

/* [Box dimensions] */
// length, total, includes wall thickness
Length = 105;
// width, total, includes wall thickness
Width = 59.5;
// height, total includes wall thickness
Height = 14.0; // 23.5; -->> 15.5 -->> 14.0
// wall thickness
Thick = 1.5; // [2:5]

// diference 1.6 -->> 1.6.s
deltaH = 7.5; 

/* [Box options] */
// filet diameter
Filet = 2; // [0.1:12]
// filet smoothness
Resolution = 50; // [1:100]

module prism(l, w, h) {
    polyhedron(
       points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
       faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}

// round_box module
module round_box($l=Length, $w=Width, $h=Height) {
    $fn=Resolution;
    translate([0, Filet, Filet]) {
        minkowski() {
            cube([$l-(Filet/2), $w-(2*Filet), $h-(2*Filet)]);
            rotate([0, 90, 0]) {
                cylinder(r=Filet);
            }
            rotate([0, 0, 90]) {
                cylinder(r=Filet);
            }
            rotate([90, 0, 0]) {
                cylinder(r=Filet);
            }
        }
    }
} // end of round_box module

// box module
module box() {
    $fn=Resolution;
    // assemble box and it's holes
    difference() {
        // make a rounded box
        translate([Filet+2, Filet+1, Filet]) {
            round_box(Length-8, Width-5, Height-5);
        }
        // make the rounded box empty inside
        translate([Thick, Thick, Thick]) {
            translate([0, 0, 0]) {
                minkowski() {
                    cube([Length-3, Width-3, Height-3]);
                }
            }
            // make the rear opening corners round
             translate([Length-3.5, 2, 2]) {
                 minkowski() {
                    cube([1, Width-7, Height-7]);
                     rotate([0, 90, 0]) {
                        cylinder(r=Filet);
                    }
                  }
            }
        }
        // version on the rear opening
        translate([Length-3.5, Width/4, Thick-0.3]) {
            rotate([0, 0, 90]) {
                color("RoyalBlue")
                linear_extrude(0.4) {
                    text(text=Version, size=3);
                }
            }
        }
        // logo substracted from bottom part
        mirror([0, 1, 0]) {
            rotate([0, 0, -90]) {
                translate([Width/2+1, 12, 0]) {
                    logo2(0.3);
                }
            }
        }
        // logo substracted from top part
        rotate([180, 0, 0]) {
            translate([Length/2, -Width/2, -Height]) {
                rotate([0, 0, -90]) {
                    mirror([1, 0, 0]) {
                        logo(0.3);
                    }
                }
            }
        }
        // lower left lid fixation screw head hole
        translate([Length-4.5, 0.5, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=5);
            }
        }
        // lower left lid fixation screw hole
        translate([Length-4.5, 2, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        /*
        // upper left lid fixation screw head hole
         translate([Length-4.5, 0.5, Height-5.5]) {
             rotate([90, 0, 0]) {
                 cylinder(d=5);
            }
         }
        // upper left lid fixation screw hole
        translate([Length-4.5, 2, Height-5.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        */
        /*
        // lower right lid fixation screw head hole
        translate([Length-4.5, Width+0.5, 5.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=5);
            }
        }
        // lower right lid fixation screw hole
        translate([Length-4.5, Width+1, 5.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        */
        // upper right lid fixation screw head hole   // Height-5.5 -->> 8.5
        translate([Length-4.5, Width+0.5, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=5);
            }
        }
        // upper right lid fixation screw hole   // Height-5.5 -->> 8.5
        translate([Length-4.5, Width+1, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        // DC/DC usb charging hole // Length-19.25 -->> Length-14.25 -->> 15.0
        translate([Length-15.0, 2, 5.5]) {
            rotate([90, 0, 0]) {
                minkowski() {
                    cylinder(d=Filet);
                    cube([5.5, 1, 1]);
                }
            }
        }
        // headpad hole // Width-14.3 -->> 15.0,  12.75 -->> 4.5
        translate([-0.1, Width-15.0, 4.5]) {
            minkowski() {
                cube([1, 7.5, 5]);
                rotate([0, 90, 0]) {
                    cylinder(d=Filet, 3);
                }
            }
        }
        // 200Hz LED hole  12.5 -->> 4.0 -->> 3.5
        translate([-0.1, 6, 3.5]) {
            minkowski() {
                cube([1, 2, 0.25]);
                rotate([0, 90, 0]) {
                    cylinder(d=Filet/2, 3);
                }
            }
        }
        // button hole  -->> no need for s
        /*
         translate([0.5, 3, 3.25]) {
             sphere(r=7);
         }
        // canal for button
         translate([4.25, 1, 3.5]) {
             minkowski() {
                 cube([8.5, 1, 3]);
                 rotate([90, 0, 0]) {
                    cylinder(d=Filet*2);
                }
            }
        }
        */
    } // end of difference holes
    /*difference() {
        // button support cube
        translate([1.5, 1.5, 1.5]) {
            cube([6, 9, 8.75]);
        }
        // button hole
        translate([1.49, 5, 6]) {
            //sphere(r=10);
            rotate([0, 90, 0]) {
                cylinder(d=7, 7);
            }
        }
        // button sphere
        translate([0.5, 3, 3.25]) {
            sphere(r=7);
        }
    }*/
    // left upper PCB holding rail
    translate([1.5, 1.5, 12-deltaH]) {
        cube([Length-3-20, 2.25, 1]);
        translate([0, 0, 2.5]) {
            rotate([-90, 0, 0]) {
                prism(Length-3-20, 1.5, 2.25);
            }
        }
    }
    // left middle PCB psuher
    translate([1.5, 1.5, 10.5-deltaH]) {
        cube([Length-3-20, 0.6, 1.5]);
    }
    // right upper pcb holding rail
    translate([1.5, Width-4, 12-deltaH]) {
        cube([Length-3, 3, 1]);
        translate([0, 0, 1]) {
            prism(Length-3, 2.5, 1);
        }
    }
    // right middle pcb holding rail
    translate([1.5, Width-3.5, 10-deltaH]) {
        cube([Length-3, 2, 2]);
    }
    // right lower PCB holding rail
    /*translate([1.5, Width-4, 9.25]) {
        cube([Length-3, 3, 1]);
        translate([0, 2.5, -1]) {
            rotate([90, 0, 0]) {
                prism(Length-3, 1, 2.5);
            }
        }
    }*/
    // upper middle lid support
    translate([Length-2.8, Width/2-2, Height-2]) {
        minkowski() {
            cube([0.25, 4, 1]);
            rotate([0, 90, 0]) {
                cylinder(d=1, 1);
            }
        }
        translate([0, 4, 0]) {
            rotate([90, 0, -90]) {
                minkowski() {
                    prism(4, 1, 1);
                    rotate([0, 180, 0]) {
                        cylinder(d=1, 0.01);
                    }
                }
            }
        }
    }
    // upper left lid support
    translate([Length-2.8, 2, Height-2]) {
        minkowski() {
            cube([0.25, 1, 1]);
            rotate([0, 90, 0]) {
                cylinder(d=1, 1);
            }
        }
        translate([0, 1, 0]) {
            rotate([90, 0, -90]) {
                minkowski() {
                    prism(1, 1, 1);
                    rotate([0, 180, 0]) {
                        cylinder(d=1, 0.01);
                    }
                }
            }
        }
    }
    // upper right lid support
    translate([Length-2.8, Width-3, Height-2]) {
        minkowski() {
            cube([0.25, 1, 1]);
            rotate([0, 90, 0]) {
                cylinder(d=1, 1);
            }
        }
        translate([0, 1, 0]) {
            rotate([90, 0, -90]) {
                minkowski() {
                    prism(1, 1, 1);
                    rotate([0, 180, 0]) {
                        cylinder(d=1, 0.01);
                    }
                }
            }
        }
    }
    // lower right lid support
    /*
    translate([Length-2.8, Width-3, 1]) {
        minkowski() {
            cube([0.25, 1, 1]);
            rotate([0, 90, 0]) {
                cylinder(d=1, 1);
            }
        }
        translate([0, 0, 1]) {
            rotate([-90, 0, 90]) {
                minkowski() {
                    prism(1, 1, 1);
                    rotate([0, 180, 0]) {
                        cylinder(d=1, 0.01);
                    }
                }
            }
        }
    }
    */
    // lower left lid support
    /*translate([Length-2.8, Width/2-2, 1]) {
        minkowski() {
            cube([0.25, 4, 1]);
            rotate([0, 90, 0]) {
                cylinder(d=1, 1);
            }
        }
    }*/
} // end of module shell

// logo module
module logo(h) {
    scale([25.4/90, -25.4/90, 1]) {
        union() {
            linear_extrude(height=h) {
                polygon([[1.972725,30.118110],[-1.513255,30.118110],[-1.989391,30.021940],[-2.378289,29.759701],[-2.640532,29.370805],[-2.736705,28.894660],[-2.640532,28.418512],[-2.378289,28.029609],[-1.989391,27.767364],[-1.513255,27.671190],[1.972725,27.671190],[2.448859,27.767364],[2.837760,28.029609],[3.100009,28.418512],[3.196185,28.894660],[3.100009,29.370805],[2.837760,29.759701],[2.448859,30.021940]]);
                polygon([[11.882805,22.350380],[-12.156045,22.350380],[-12.631912,22.254205],[-13.020850,21.991956],[-13.283256,21.603050],[-13.379525,21.126900],[-13.283256,20.650742],[-13.020850,20.261836],[-12.631912,19.999592],[-12.156045,19.903420],[11.882805,19.903420],[12.358959,19.999592],[12.747865,20.261836],[13.010111,20.650742],[13.106285,21.126900],[13.010111,21.603050],[12.747865,21.991956],[12.358959,22.254205]]);
                polygon([[5.949825,26.118670],[-6.100455,26.118670],[-6.576593,26.022495],[-6.965494,25.760246],[-7.227740,25.371340],[-7.323915,24.895190],[-7.227740,24.419032],[-6.965494,24.030126],[-6.576593,23.767882],[-6.100455,23.671710],[5.949825,23.671710],[6.425979,23.767882],[6.814885,24.030126],[7.077131,24.419032],[7.173305,24.895190],[7.077131,25.371340],[6.814885,25.760246],[6.425979,26.022495]]);
                polygon([[16.469885,18.312950],[-16.437805,18.312950],[-16.913953,18.216777],[-17.302856,17.954533],[-17.565101,17.565632],[-17.661275,17.089490],[-17.565101,16.613335],[-17.302856,16.224425],[-16.913953,15.962175],[-16.437805,15.866000],[16.469885,15.866000],[16.946031,15.962175],[17.334931,16.224425],[17.597173,16.613335],[17.693345,17.089490],[17.597173,17.565632],[17.334931,17.954533],[16.946031,18.216777]]);
                polygon([[-1.263475,9.250060],[-0.832795,9.198660],[-0.220880,8.928285],[0.265531,8.465103],[0.596094,7.849546],[0.740465,7.122050],[3.179165,-19.066108],[8.983145,-4.889150],[9.415530,-4.186742],[9.981590,-3.655806],[10.647827,-3.319940],[11.380745,-3.202740],[18.674945,-3.202740],[19.150815,-3.298915],[19.539749,-3.561164],[19.802149,-3.950070],[19.898415,-4.426220],[19.802149,-4.902380],[19.539749,-5.291289],[19.150815,-5.553536],[18.674945,-5.649710],[11.380745,-5.649710],[11.211365,-5.900710],[4.622835,-21.809349],[4.244882,-22.390774],[3.737968,-22.799057],[3.142850,-23.011499],[2.500285,-23.005401],[1.848395,-22.752579],[1.330627,-22.288737],[0.979004,-21.654641],[0.825545,-20.891058],[-1.630345,5.605720],[-6.484475,-3.346800],[-7.046390,-4.093512],[-7.730146,-4.651719],[-8.503275,-5.001356],[-9.333305,-5.122360],[-17.633595,-5.122360],[-18.109760,-5.026183],[-18.498673,-4.763930],[-18.760921,-4.375017],[-18.857095,-3.898860],[-18.760921,-3.422711],[-18.498673,-3.033815],[-18.109760,-2.771579],[-17.633595,-2.675410],[-9.333305,-2.675410],[-8.947194,-2.522642],[-8.594015,-2.107540],[-2.916225,8.248810],[-2.197590,8.987843],[-1.263435,9.250070]]);
            }
            difference() {
                linear_extrude(height=h) {
                    polygon([[19.184025,14.399540],[-19.181965,14.399540],[-19.546155,13.998370],[-21.107020,12.109857],[-22.476769,10.100642],[-23.650163,7.984265],[-24.621961,5.774269],[-25.386925,3.484195],[-25.939815,1.127584],[-26.275392,-1.282021],[-26.388415,-3.731080],[-26.251912,-6.425079],[-25.851314,-9.042154],[-25.199988,-11.568939],[-24.311302,-13.992063],[-23.198623,-16.298160],[-21.875318,-18.473862],[-20.354754,-20.505799],[-18.650299,-22.380604],[-16.775319,-24.084909],[-14.743182,-25.605345],[-12.567255,-26.928545],[-10.260906,-28.041140],[-7.837501,-28.929762],[-5.310408,-29.581043],[-2.692993,-29.981615],[0.001375,-30.118110],[2.695597,-29.981615],[5.312838,-29.581043],[7.839737,-28.929762],[10.262931,-28.041140],[12.569057,-26.928545],[14.744754,-25.605345],[16.776660,-24.084909],[18.651411,-22.380604],[20.355647,-20.505799],[21.876004,-18.473862],[23.199120,-16.298160],[24.311634,-13.992063],[25.200182,-11.568939],[25.851403,-9.042154],[26.251935,-6.425079],[26.388415,-3.731080],[26.275421,-1.282421],[25.939928,1.126997],[25.387167,3.483584],[24.622372,5.773747],[23.650775,7.983899],[22.477608,10.100446],[21.108104,12.109800],[19.547495,13.998370],[19.184025,14.399540]]);
                }
                translate([0, 0, -0.1]) {
                    linear_extrude(height=h+2*0.1) {
                        polygon([[-18.090175,11.952590],[18.091535,11.952590],[19.426836,10.265659],[20.598308,8.478008],[21.601569,6.600922],[22.432241,4.645685],[23.085944,2.623582],[23.558297,0.545897],[23.844920,-1.576085],[23.941435,-3.731080],[23.817616,-6.175294],[23.454239,-8.549708],[22.863425,-10.842196],[22.057297,-13.040629],[21.047975,-15.132879],[19.847581,-17.106821],[18.468236,-18.950325],[16.922061,-20.651265],[15.221179,-22.197513],[13.377710,-23.576941],[11.403776,-24.777423],[9.311498,-25.786830],[7.112997,-26.593035],[4.820396,-27.183911],[2.445814,-27.547330],[0.001375,-27.671165],[-2.443211,-27.547330],[-4.817967,-27.183911],[-7.110766,-26.593035],[-9.309480,-25.786830],[-11.401985,-24.777423],[-13.376153,-23.576941],[-15.219858,-22.197513],[-16.920974,-20.651265],[-18.467373,-18.950325],[-19.846929,-17.106821],[-21.047516,-15.132879],[-22.057008,-13.040629],[-22.863277,-10.842196],[-23.454197,-8.549708],[-23.817642,-6.175294],[-23.941485,-3.731080],[-23.844967,-1.575686],[-23.558322,0.546484],[-23.085914,2.624193],[-22.432107,4.646206],[-21.601266,6.601288],[-20.597754,8.478203],[-19.425936,10.265716]]);
                    }
                }
            }
        }
    }
}

// logo2 module
module logo2(h) {
  fudge = 0.1;
  scale([25.4/90, -25.4/90, 1]) union() {
    difference() {
       linear_extrude(height=h)
         polygon([[48.899675,-4.846930],[49.624399,-6.564051],[50.639485,-8.071270],[51.941675,-9.332420],[53.526675,-10.310760],[55.395086,-10.937781],[57.546315,-11.146790],[59.697731,-10.937781],[61.566345,-10.310760],[63.151344,-9.332420],[64.453525,-8.071270],[65.468170,-6.564051],[66.193345,-4.846930],[66.774095,-1.057180],[66.193345,2.734200],[65.468170,4.450922],[64.453525,5.957720],[63.151344,7.216468],[61.566345,8.183930],[59.697731,8.801165],[57.546315,9.007040],[55.395086,8.801165],[53.526675,8.183930],[51.941675,7.216468],[50.639485,5.957720],[49.624399,4.450923],[48.899675,2.734200],[48.318925,-1.057180]]);
       translate([0, 0, -fudge])
         linear_extrude(height=h+2*fudge)
           polygon([[51.259765,1.817110],[52.447445,4.366740],[53.371348,5.388175],[54.524825,6.187610],[55.913973,6.703623],[57.546315,6.876030],[59.178999,6.703623],[60.568195,6.187610],[61.721662,5.388175],[62.645555,4.366740],[63.833265,1.817110],[64.210335,-1.057180],[63.833265,-3.929830],[62.645555,-6.479460],[61.721662,-7.501514],[60.568195,-8.300330],[59.178999,-8.816446],[57.546315,-8.988350],[55.913972,-8.816446],[54.524825,-8.300330],[53.371348,-7.501514],[52.447445,-6.479460],[51.259765,-3.929830],[50.882675,-1.057180]]);
    }
    difference() {
       linear_extrude(height=h)
         polygon([[22.060435,8.467790],[-0.501065,8.467790],[-0.715225,8.231880],[-2.438603,5.939782],[-3.700105,3.395615],[-4.475082,0.663085],[-4.738885,-2.194100],[-4.423038,-5.317329],[-3.517419,-8.228171],[-2.084916,-10.863736],[-0.188412,-13.161134],[2.109205,-15.057474],[4.745051,-16.489867],[7.656239,-17.395423],[10.779885,-17.711250],[13.903344,-17.395423],[16.814295,-16.489867],[19.449876,-15.057474],[21.747224,-13.161134],[23.643477,-10.863736],[25.075773,-8.228171],[25.981250,-5.317329],[26.297045,-2.194100],[26.033308,0.662744],[25.258506,3.395311],[23.997257,5.939668],[22.274175,8.231880],[22.060435,8.467790]]);
       translate([0, 0, -fudge])
         linear_extrude(height=h+2*fudge)
           polygon([[0.140975,7.028840],[21.417985,7.028840],[22.892116,4.985575],[23.970579,2.731939],[24.632767,0.321018],[24.858075,-2.194100],[24.571574,-5.027741],[23.750089,-7.668670],[22.450643,-10.059834],[20.730263,-12.144179],[18.645971,-13.864651],[16.254795,-15.164198],[13.613758,-15.985766],[10.779885,-16.272300],[7.945824,-15.985766],[5.304546,-15.164198],[2.913099,-13.864651],[0.828534,-12.144179],[-0.892102,-10.059834],[-2.191760,-7.668670],[-3.013391,-5.027741],[-3.299945,-2.194100],[-3.074622,0.321364],[-2.412341,2.732246],[-1.333632,4.985691],[0.140975,7.028840]]);
    }
    difference() {
       linear_extrude(height=h)
         polygon([[-16.539175,-10.688860],[-14.087689,-10.351346],[-12.236015,-9.339020],[-11.072711,-7.740865],[-10.684945,-5.643630],[-10.884071,-3.997440],[-11.480645,-2.568120],[-12.516047,-1.454816],[-14.030265,-0.760140],[-14.030265,-0.706540],[-12.667945,-0.166530],[-11.831915,0.738050],[-11.372555,1.911640],[-11.143485,3.260260],[-11.062485,4.689930],[-10.927795,6.120030],[-10.617255,7.455330],[-10.010295,8.575280],[-12.870465,8.575280],[-13.234225,7.765460],[-13.356025,6.619300],[-13.410125,5.256580],[-13.571865,3.826480],[-13.841665,2.491170],[-14.354245,1.385740],[-15.271745,0.629570],[-16.782475,0.346860],[-23.041205,0.346860],[-23.041205,8.575280],[-25.604545,8.575280],[-25.604545,-10.688900],[-16.539295,-10.688900]]);
       translate([0, 0, -fudge])
         linear_extrude(height=h+2*fudge)
           polygon([[-15.999545,-1.946630],[-14.583595,-2.473740],[-13.612045,-3.525540],[-13.247865,-5.237920],[-13.450425,-6.560430],[-14.057685,-7.612520],[-15.116290,-8.300890],[-16.674275,-8.530410],[-23.041085,-8.530410],[-23.041085,-1.811930],[-17.699435,-1.811930],[-15.999545,-1.946630]]);
    }
    linear_extrude(height=h) {
      polygon([[44.947675,-10.688860],[44.947675,-8.530410],[34.857655,-8.530410],[34.857655,-2.405990],[43.706335,-2.405990],[43.706335,-0.247550],[34.857655,-0.247550],[34.857655,8.575320],[32.294305,8.575320],[32.294305,-10.688860],[44.947675,-10.688860]]);
      polygon([[-51.476555,-10.688860],[-51.476555,-8.530410],[-62.214275,-8.530410],[-62.214275,-2.405990],[-52.205315,-2.405990],[-52.205315,-0.247550],[-62.214275,-0.247550],[-62.214275,6.416890],[-51.395905,6.416890],[-51.395905,8.575320],[-64.777615,8.575320],[-64.777615,-10.688860],[-51.476555,-10.688860]]);
      polygon([[10.036085,5.439590],[10.289345,5.409390],[10.935226,4.978021],[11.214515,4.188220],[12.648615,-11.211980],[16.061705,-2.875080],[16.648852,-2.149800],[17.471635,-1.883370],[21.761065,-1.883370],[22.269619,-2.094145],[22.480535,-2.602850],[22.269619,-3.111564],[21.761065,-3.322340],[17.471635,-3.322340],[17.372035,-3.469940],[13.497585,-12.825170],[12.977226,-13.407178],[12.249395,-13.528520],[11.561569,-13.107079],[11.264545,-12.285160],[9.820335,3.296530],[6.965825,-1.968090],[6.233289,-2.735458],[5.290535,-3.012220],[0.409475,-3.012220],[-0.099243,-2.801444],[-0.310015,-2.292730],[-0.099243,-1.784035],[0.409475,-1.573270],[5.290535,-1.573270],[5.725285,-1.239330],[9.064165,4.850820],[9.486767,5.285422],[10.036105,5.439630]]);
      polygon([[20.464355,10.769110],[1.112665,10.769110],[0.603965,10.558340],[0.393195,10.049640],[0.603965,9.540931],[1.112665,9.330160],[20.464355,9.330160],[20.973055,9.540931],[21.183825,10.049640],[20.973055,10.558340]]);
      polygon([[14.277935,15.359340],[7.191645,15.359340],[6.682949,15.148565],[6.472175,14.639860],[6.682949,14.131151],[7.191645,13.920380],[14.277935,13.920380],[14.786640,14.131151],[14.997415,14.639860],[14.786640,15.148565]]);
      polygon([[-83.176835,-10.688860],[-73.032765,4.933160],[-72.978665,4.933160],[-72.978665,-10.688860],[-70.550445,-10.688860],[-70.550445,8.575320],[-73.356555,8.575320],[-83.419565,-6.884980],[-83.473565,-6.884980],[-83.473565,8.575320],[-85.901815,8.575320],[-85.901815,-10.688860],[-83.176735,-10.688860]]);
      polygon([[-33.292745,7.158540],[-34.382153,7.967116],[-35.680645,8.544716],[-38.904585,9.006840],[-42.219714,8.565131],[-44.718475,7.239600],[-45.633376,6.225524],[-46.286832,4.949850],[-46.809555,1.614450],[-46.809555,-10.688860],[-44.246625,-10.688860],[-44.246625,1.614450],[-43.902612,3.890950],[-42.870175,5.540120],[-41.191063,6.541601],[-38.904585,6.875830],[-36.743074,6.541601],[-35.168055,5.540120],[-34.207057,3.890950],[-33.886395,1.614450],[-33.886395,-10.688860],[-31.323445,-10.688860],[-31.323445,1.614450],[-31.815975,4.848975],[-32.431407,6.119414],[-33.292745,7.158540]]);
      polygon([[17.766875,13.143360],[3.630595,13.143360],[3.122040,12.932585],[2.911115,12.423880],[3.122040,11.915171],[3.630595,11.704400],[17.766875,11.704400],[18.275584,11.915171],[18.486355,12.423880],[18.275584,12.932585],[17.766875,13.143360]]);
      polygon([[69.741005,-10.688860],[72.816535,-10.688860],[77.618555,-3.160960],[82.636735,-10.688860],[85.496505,-10.688860],[79.130505,-1.326780],[85.901815,8.575320],[82.772645,8.575320],[77.592335,0.616300],[72.249895,8.575320],[69.390535,8.575320],[76.081605,-1.326780],[69.741005,-10.688860]]);
      polygon([[11.939155,17.711250],[9.889195,17.711250],[9.380504,17.500485],[9.169735,16.991790],[9.380504,16.483085],[9.889195,16.272310],[11.939155,16.272310],[12.447851,16.483085],[12.658625,16.991790],[12.447851,17.500485]]);
    }
  }
}

module rear_panel() {
    $fn=Resolution;
    // upper left fixation leg support rounding
    intersection() {
        translate([-6, 3.5+0.15, Height-4.65]) {
            minkowski() {
                cube([5, 0.5, 0.5]);
                rotate([0, 90, 0]) {
                    cylinder(r=Filet);
                }
            }
        }
        translate([-4.1, 3.15, Height-4.01]) {
            rotate([0, 0, -90]) {
                prism(1.5, 4.1, 0.75);
            }
        }
    }
    // upper left lid fixation leg suppport
    translate([-4.1, 1.65, Height-7.99]) {
        rotate([0, 180, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
 
    // lower left lid fixation leg suppport
    translate([-4.1, 3.15, 8.99]) {
        rotate([0, 0, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
    translate([-4.1, 1.65, 5.01]) {
        rotate([0, 180, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
 
    // lower right lid fixation leg support rounding
    intersection() {
        translate([-6, Width-4.15, 3.15]) {
            minkowski() {
                cube([5, 0.5, 0.5]);
                rotate([0, 90, 0]) {
                    cylinder(r=Filet);
                }
            }
        }
        translate([-4.1, Width-3.15, 3.01]) {
            rotate([0, 180, -90]) {
                prism(1.5, 4.1, 0.75);
            }
        }
    }
    // lower right lid fixation leg suppport rounding
    translate([-4.1, Width-1.65, 6.99]) {
        rotate([0, 0, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
    
    
    // upper right lid fixation leg suppport
    translate([-4.1, Width-3.15, Height-7.99]) {
        rotate([0, 180, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
    translate([-4.1, Width-1.65, Height-4.01]) {
        rotate([0, 0, -90]) {
            prism(1.5, 4.1, 0.75);
        }
    }
 
    // upper left lid fixation leg
    difference() {
        // left lid fixation screw leg  // 7-> 6.5
        translate([-4, 2.654, Height-6.5]) {
            minkowski() {
                cube([4.5, 0.5, 2]);
                rotate([90, 0, 0]) {
                    cylinder(d=Filet);
                }
            }
        }
        // left lid fixation hole //  Height-6 -->> 8.5
        translate([-3, 4, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
    }
    
    // lower left lid fixation leg
    difference() {
        /*
        // left lid fixation screw leg // 6-> 6.5
        translate([-4, 2.654, 6.5]) {
            minkowski() {
                cube([4.5, 0.5, 2]);
                rotate([90, 0, 0]) {
                    cylinder(d=Filet);
                }
            }
        }
        // left lid fixation hole // 7 ->> 8.0
        translate([-3, 4, 8.0]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        */
    }
    
    // upper right lid fixation leg
    difference() {
         
        // right lid fixation leg // 7 --> 6.5
        translate([-4, Width-2.154, Height-6.5]) {
            minkowski() {
                cube([4.5, 0.5, 2]);
                rotate([90, 0, 0]) {
                    cylinder(d=Filet);
                }
            }
        }
        // right lid fixation hole  // Height-6 -->> 8.5
        translate([-3, Width-1, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
         
    }
    
    // lower right lid fixation leg
    difference() {
        /*
        // right lid fixation leg
        translate([-4, Width-2.154, 4]) {
            minkowski() {
                cube([4.5, 0.5, 2]);
                rotate([90, 0, 0]) {
                    cylinder(d=Filet);
                }
            }
        }
        // right lid fixation hole  // 5 -->> 8.5
        translate([-3, Width-1, 8.5]) {
            rotate([90, 0, 0]) {
                cylinder(d=2.5, 3);
            }
        }
        */
    }
    
    // read panel and its holes
    difference() {
        // rear panel
        translate([0, 3.5+0.15, 3.15]) {
            minkowski() {
                cube([0.5, Width-7.3, Height-7.3]);
                rotate([0, 90, 0]) {
                    cylinder(r=Filet);
                }
            }
        }
        /*
        // charging indication hole
        translate([-0.1, 7.5, 4]) {
            minkowski() {
                cube([1, 5, 0.25]);
                rotate([0, 90, 0]) {
                    cylinder(d=Filet/2, 3);
                }
            }
        }
        // power indication hole
        translate([-0.1, 35, 4]) {
            minkowski() {
                cube([1, 2, 0.25]);
                rotate([0, 90, 0]) {
                    cylinder(d=Filet/2, 3);
                }
            }
        }
        */
    }
}

// box();
translate([Length + 11.5, 0, 0.5]) {
 rotate([0, 90, 0]) 
// translate([Length + 11.5, 0, 0.5]) {
     rear_panel();
}