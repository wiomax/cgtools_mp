# Author: Zun-Jing Wang 
# Sep. 23 2008 done

namespace eval ::cgtools::utils {
    namespace export maxpartid 
    namespace export maxmoltypeid
    namespace export listnmols
    namespace export minpartid
    namespace export minmoltype
    namespace export listmoltypes
    namespace export listmollengths
}

# Routines used by the analysis package which might be used by several
# different actual analysis functions


#
# ::cgtools::utils::maxpartid --
#  
# find the maximum particle id in a topology
# 
# 
proc ::cgtools::utils::maxpartid { topo } { 
    mmsg::debug [namespace current] "finding maxpartid"
    set maxpart 0
    foreach mol $topo {
	for { set p 1 } { $p < [llength $mol] } { incr p } {
	    if { [ lindex $mol $p] > $maxpart } {
		set maxpart [ lindex $mol $p]
	    }
	}
    }

    return $maxpart
}

#
# ::cgtools::utils::maxmoltypeid --
#  
# find the maximum mol type id in a topology
# 
# 
proc ::cgtools::utils::maxmoltypeid { topo } { 
    mmsg::debug [namespace current] "finding maxmoltypeid"
    set maxtype 0
    foreach mol $topo {
	    if { [ lindex $mol 0] > $maxtype } {
		set maxtype [ lindex $mol 0]
	    }
    }

    return $maxtype
}

#
# ::cgtools::utils::listnmols --
#  
# Make a list containing the number of molecules of each molecule
# type.  Actually this is a list of lists. Each of the inner lists
# consists of the molecule type number and then the actual number of
# those mols
# 
# 
proc ::cgtools::utils::listnmols { topo } { 
    mmsg::debug [namespace current] "finding listnmols"
    set moltypes [listmoltypes $topo]
    set ntype 0
    mmsg::debug [namespace current] "     moltypes: $moltypes"

    foreach type $moltypes {
	foreach mol $topo {
	    set thistype [lindex $mol 0]
	    if { $thistype == $type } {
		incr ntype
	    }
	}       
	lappend nmolslist [list $type $ntype]
	set ntype 0
    }
    return $nmolslist
}


#
# ::cgtools::utils::minpartid --
#
# Get the minimum particle id for this topology
# 
# 
proc ::cgtools::utils::minpartid { topo } {  
    mmsg::debug [namespace current] "finding minmolpartid"
    set startpart [lindex $topo 0 1 ]
    foreach mol $topo {
	for { set i 1 } {$i < [llength $mol] } { incr i } {
	    set thisid [lindex $mol $i]
	    if { $thisid < $startpart } {
		set startpart $thisid
	    }
	}
    }
    return $startpart
}

#
# ::cgtools::utils::minmoltype --
#
# Get the minimum moltype for this topology
# 
# 
proc ::cgtools::utils::minmoltype { topo } {  
    mmsg::debug [namespace current] "finding minmoltype"
    set moltypes [listmoltypes $topo]
    set startmol [lindex $moltypes 0]
    foreach tp $moltypes {
	if { $tp < $startmol } {
	    set startmol $tp
	}
    }
    return $startmol
}
#
# ::cgtools::utils::listmoltypes --
# 
# Make a list of all the molecule types in a topology
# 
# Makes a check for duplication which would occur for an unsorted
# topology
#
proc ::cgtools::utils::listmoltypes { topo } {  
    mmsg::debug [namespace current] "finding listmoltypes"
    set currmoltype [lindex [lindex $topo 0] 0]
    foreach mol $topo {
	set moltype [lindex $mol 0]
	if { $moltype != $currmoltype } {
	    lappend typeslist $currmoltype
	    set currmoltype $moltype
	}
    }
    lappend typeslist $currmoltype

    # Check for duplication
    set reducedlist [lindex $typeslist 0]
    set duplicate 0
    mmsg::debug [namespace current] "     now looping over [llength $typeslist] in typeslist"
    flush stdout    
    for { set i 0 } { $i < [llength $typeslist] } { incr i } {
	set tp1 [lindex $typeslist $i]
	if { [lsearch $reducedlist $tp1] != -1 } {
	} else {
	    mmsg::debug [namespace current] "     added type $tp1"
	    lappend reducedlist $tp1
	}
    }
    return $reducedlist
}


#
# ::cgtools::utils::listmollengths --
# Work out the length of each molecule type and return a list of these
# lengths
#
#
proc ::cgtools::utils::listmollengths { topo } { 
    mmsg::debug [namespace current] "finding listmollengths"
    set moltypes [listmoltypes $topo ]
 

    foreach type $moltypes {
	set lenchecksum 0
	set nchecksum 0
	foreach mol $topo {
	    set thistype [lindex $mol 0]
	    if { $thistype == $type } {
		set thislen [expr [llength $mol] - 1]
		set lenchecksum [expr $lenchecksum + $thislen]
		incr nchecksum
	    }

	}
	set lenchecksum [expr int($lenchecksum/(1.0*$nchecksum))]
	if { $lenchecksum != $thislen } {
	    mmsg::err [namespace current] "molecules of same type have different lengths"
	}
	lappend mollengths [list $type $thislen]
    }
    return $mollengths
}
