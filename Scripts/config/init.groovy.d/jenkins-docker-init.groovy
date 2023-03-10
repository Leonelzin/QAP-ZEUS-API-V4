#!groovy

import hudson.slaves.*
import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

/*
* Disabling CSRF Protection
*/
instance.setCrumbIssuer(new DefaultCrumbIssuer(false));
instance.save();

/*
* Creating an user (automatedtests)
*/
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("automatedtests", "automatedtests")
instance.setSecurityRealm(hudsonRealm)

/*
* Given permission to this user
*/
def strategy = new GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, "automatedtests")
instance.setAuthorizationStrategy(strategy)
instance.save();
Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
// instance.setAuthorizationStrategy(strategy)

/*
* Creating a node that will be attached to main job
*/
DumbSlave automatedTestsDumbSlave = new DumbSlave(
        "Default Slave",                        // Agent name, usually matches the host computer's machine name
        "Default Slave",                        // Agent description
        "/tmp/default-slave-workspace/",        // Workspace on the agent's computer
        2,                                      // Number of executors
        Mode.NORMAL,                            // "Usage" field, EXCLUSIVE is "only tied to node", NORMAL is "any"
        "",                                     // Labels
        new JNLPLauncher(),                     // Launch strategy, JNLP is the Java Web Start setting services use
        RetentionStrategy.INSTANCE)             // Is the "Availability" field and INSTANCE means "Always"

instance.addNode(automatedTestsDumbSlave)
instance.save();

/*
* Creating a job to attach the node above
*/



instance.save();
