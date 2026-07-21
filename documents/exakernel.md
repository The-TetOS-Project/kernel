## Structure of a exakernel:



### Kernel
- Runs in ring 0
- The kernel itself
- Bugs can be fatal

### Module
- Runs in ring 0
- Inserts itself into kernel
- Bugs can be detrimental but contained

### Service
- Runs in ring 3
- Attaches itself to module
- Bugs can be annoying but handled