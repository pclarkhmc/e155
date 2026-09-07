if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/pclark/Downloads/iCE40_demo"
if {![file exists {C:/Users/pclark/Downloads/iCE40_demo/impl_1}]} {
  file mkdir {C:/Users/pclark/Downloads/iCE40_demo/impl_1}
}
cd {C:/Users/pclark/Downloads/iCE40_demo/impl_1}
# synthesize IPs
# synthesize VMs
# synthesize top design
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o iCE40_demo_impl_1_syn.udb iCE40_demo_impl_1.vm] [list iCE40_demo_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
