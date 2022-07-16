# FLS-Multimedia2022
This repository contains MATLAB R2022a (9.12.0.1884302, maci64 bit, February 16 2022) implementation of Flying Light Speck (FLS) concepts presented in our ACM Multimedia 2022 paper.  It includes the Rose Clip data set consisting of 115 point clouds with each point cloud requiring 65K FLSs to illuminate.  

Author:  Shahram Ghandeharizadeh (shahram@usc.edu)

# Features

  * Two algorithms to deploy FLSs to illuminate a single point cloud:  MinDist and QuotaBalanced.
  * One algorithm to compute flight path of FLSs to illuminate motion illuminations consisting of a sequence of point clouds:  Motill.
  * All algorithms implemented using MATLAB R2022a academic edition. 
  * Rose Clip data set consisting of 115 point clouds.
  * The algorithms are detailed in a paper that appeared in the ACM Multimedia 2022 paper with an extended arXiv version.
  * Click here for Bibtex citation of the [ACM Multimedia 2022 paper](https://github.com/shahramg/FLS-Multimedia2022#citations).

# Documentation

This section describes how to run and benchmark algorithms for static and motion illumination in turn.

## Static Illuminations

We use the [Princeton Shape Benchmark](https://shape.cs.princeton.edu/benchmark/) to create static point clouds to evaluate MinDist and QuotaBalanced algorithms.  While the choice of this benchmark is somewhat arbitrary, we were motivated to use it for several reasons.  First, it contains a database of 3D polygonal models collected from the web.  Second, it consists of a large number of shapes.  Third, it provides existing software tools for evaluating shape-based retrieval and analysis algorithsm.  As a part of our future research direction, we intend to explore alternative retrieval techniques with FLS illuminations.  The benchmark and its existing software are a good comparison yardstick.  

Below, we describe how to create a point cloud from a Princeton 3D Shape Model.  Subsequently, we describe how to run the MinDist and QuotaBalanced algorithms.  This workflow is captured in the MATLAB file workflowMinDist.m.  It is trivial to change this file to execute QuotaBalanced (not provided). To execute the workflow, download the Princeton Shape Benchmark database and execute the workflowMinDist function using MATLAB's Command Window:
```
workflowMinDist(false, true)
```
Make sure to provide the path to a valid Princeton Benchmark file as input.  And, modify the value of PtCldFile variable (in workflowMinDist.m) to have the name of the file that should contain the point cloud file.

Here are the individual steps of the workflow file.  Create a point cloud from a Princeton 3D Model:
1. Download the Princeton Shape Benchmark dataset.
2. Make a copy of this git repository (shahramg/FLS_Multimedia2022) available to MATLAB.
3. Launch MATLAB and change directory (cd) to cnvPrincetonShapeToPtCloud folder of this repository.
4. Run cnvPrincetonShapeToPtCld(inputfile, outputfile) where inputfile is the path to a Princeton Shape file and outputfile is the path to the point cloud output file.  Example:  
```
cnvPrincetonShapeToPtCld('/Users/flyinglightspec/src/benchmark/db/15/m1559/m1559.off', './pt1559.ptcld')
```
4. Plot the resulting point cloud file using the provided plotPtCld function in cnvPrincetonShapeToPtCloud directory.  Example:  
```
plotPtCld('./pt1559.ptcld')
```
5. Verify the point cloud looks like the jpeg file provided by the Princeton Shape Benchmark.  Example:  see /Users/flyinglightspec/src/benchmark/db/15/m1559/m1559_thumb.jpg

Use readPrincetonFile function to create a MATLAB variable named vertexList that contains the vertices of the points in a point cloud file.  This MATLAB function is in the cnvPrincetonShapeToPtCloud directory.  Example:  
```
[vertexList, minW, maxW, minH, maxH, minD, maxD] = readPrincetonFile('pt1559.ptcld')
```

Return to the parent directory (cd ..) Run MinDist or QuotaBAlanced algorithm using the vertexList variable. Example:  
```
algMinDist(vertexList, false, false) 
```
or 
```
algQuotaBalanced(vertexList, false, false)
```
MinDist and QuotaBalanced implementations use an in-memory data structure to eliminate the overhead of secondary storage (disk/SSD/NVM) accesses to read a file into memory.  This is for benchmarking purposes.  All execution times reported in the ACM Multimedia 2022 publication is based on in-memory data structures.


## Motion Illuminations
We represent a motion illumination as a stream of point clouds that must be rendered at a pre-specified rate, e.g., 24 point clouds per second.  This representation is illustrated by the RoseClip directory consisting of 115 point clouds rendered at 24 point clouds per second with a 4.79 second display time.  Each file consists of 65K points, FLS coordinates.

Three algorithms are presented in the Ghandehrizadeh ACM Multimedia 2022 paper:  Simple, Intra-Cube First (ICF), and Intra-Cube Last (ICL).  Simple is a special case of ICF with cube capacity set to max integer.  To run these algorithms, analyze workflowMotill.m that can be executed directly.  The input to this file are numFiles, cubeCapacity, and doReset.  numFiles is the number of Rose illumination files to process starting with the first one, e.g., numFiles=3 processes Scene001.ply, Scene002.ply, and Scene003.ply in the RoseClip directory.  cubeCapacity controls the number of points assigned to each cube constructed by Motill.  The Ghandeharizadeh paper reports experimental results with cubeCapacity set to 100, 1500, 10K, and infinity.  When cubeCapacity is set to infinity, ICF emulates Simple.  doReset refreshes the list of points (vertices) maintained by a point cloud by copying its backup copy to a working copy to be manipulated by an algorithm.  This prevents the overhead of reading files to run an algorithm.  

To measure the execution time of the alternative algorithms without disk I/O overhead, we read the content of these files into in-memory data structures.  This data structure is an array of instances of the inMemoryCP class.  Each instance corresponds to a point cloud and its cubes.  By staging the RoseClip point clouds in memory, one may run the different algorithms significantly faster than reading data from files.  By using the doReset flag, the original points are written to a working copy that may be manipulated by an algorithm.

The workflow consists of the following steps:
1. Read a fixed number of point clouds into memory, say 3.
```
cpa=inMemoryCP('./RoseClip/',3);
```
2. Construct a grid on the first in-memory point cloud.  If running ICF or ICL then maximum cube capacity of 1500 points provides fast execution times.  If running Simple the set maxium cube capacity to ``intmax``, i.e., replace 1500 with ``intmax``.
```
cpa{1}.createGrid(doReset, silent, 1500, 0, 0, 0, 0);
```
Set doReset to ``false`` if this is the first time running the algorithm.  Set silent to ``false`` if it is desirable to see the output of the createGrid method.
3. Clone the grid constructed for the first point cloud on each of the remaing point clouds ``i``, using the same cubeCapacity as the one used for the first point cloud.
```
cpa{i}.createGrid(doReset, silent, cubeCapacity, cpa{1}.llArray, cpa{1}.hlArray, cpa{1}.dlArray,cpa{1}.cubes);
```
The purpose of doReset and silent is the same as item (2).  By setting silent to true, the info messages of createGrid are supressed for benchmarking purposes.


# Limitations

# Getting the Source

# Executing this Software

# Citations

Shahram Ghandeharizadeh. 2022. Display of 3D Illuminations using Flying Light Specks.  In Proceedings of the 30th ACM International Conference on Multimedia} (MM '22), October 10--14, 2022, Lisboa, Portugal, DOI 10.1145/3503161.3548250, ISBN 978-1-4503-9203-7/22/10.

BibTex:
```
@inproceedings{10.1145/3503161.3548250,
author = {Ghandeharizadeh, Shahram},
title = {Display of 3D Illuminations using Flying Light Specks},
year = {2022},
isbn = {978-1-4503-9203-7/22/10},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
doi = {10.1145/3503161.3548250},
booktitle = {ACM Multimedia},
location = {Lisboa, Portugal},
series = {MM '22}
}
```
