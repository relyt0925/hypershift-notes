# hypershift-notes

This repo translates how typical IBM Cloud ROKS Openshift workflows can be executed in the hypershift flavor of Openshift

The directory structure corresponds to the command structure in the IBM Cloud ROKS CLI

At the base of the lowest level directories lies a logic.sh script that will outline the automation that needs to occur in order to simulate the automation. For example zone/add/logic.sh will show the logic in hypershift for the
`ibmcloud ks zone add` command.