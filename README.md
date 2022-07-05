# FLS-Multimedia2022
This repository contains MATLAB R2022a (9.12.0.1884302, maci64 bit, February 16 2022) implementation of Flying Light Speck (FLS) concepts presented in our ACM Multimedia 2022 paper.  It includes the Rose Clip data set consisting of 115 point clouds with each point cloud requiring 65K FLSs to illuminate.  

Author:  Shahram Ghandeharizadeh (shahram@usc.edu)

# Features

  * Two algorithms to deploy FLSs to illuminate a single point cloud:  MinDist and QuotaBalanced.
  * One algorithm to compute flight path of FLSs to illuminate motion illuminations consisting of a sequence of point clouds:  Motill.
  * All algorithms implemented using MATLAB R2022a academic edition. 
  * Rose Clip data set consisting of 115 point clouds.
  * The algorithms are detailed in a paper that appeared in the ACM Multimedia 2022 paper.  An extended arXiv version of the paper is available at https:
  * Click here for Bibtex citation of the ACM Multimedia 2022 paper and here for the arXiv version.

# Documentation

This section describes how to run and benchmark algorithms for static and motion illumination in turn.

## Static Illuminations

We use the [Princeton Shape Benchmark](https://shape.cs.princeton.edu/benchmark/) to create static point clouds to evaluate MinDist and QuotaBalanced algorithms.  While the choice of this benchmark is somewhat arbitrary, we were motivated to use it for several reasons.  First, it contains a database of 3D polygonal models collected from the web.  Second, it consists of a large number of shapes.  Third, it provides existing software tools for evaluating shape-based retrieval and analysis algorithsm.  As a part of our future research direction, we intend to explore alternative retrieval techniques with FLS illuminations.  

Below, we describe how to create a point cloud from a Princeton 3D Shape Model.  Subsequently, we describe how to run the MinDist and QuotaBalanced algorithms. 

To create a point cloud from a Princeton 3D Model:
1. Download the Princeton Shape Benchmark dataset.
2. Launch MATLAB and change directory (cd) to cnvPrincetonShapeToPtCloud folder.
3. Run cnvPrincetonShapeToPtCld(inputfile, outputfile) where inputfile is the path to a Princeton Shape file and outputfile is the path to the point cloud output file.  Example:  
```
cnvPrincetonShapeToPtCld('/Users/flyinglightspec/src/benchmark/db/15/m1559/m1559.off', './pt1559.ptcld')
```
4. Plot the resulting point cloud file using the provided plotPtCld.  Example:  
```
plotPtCld('./pt1559.ptcld')
```
5. Verify the point cloud looks like the jpeg file provided by the Princeton Shape Benchmark.  Example:  see /Users/flyinglightspec/src/benchmark/db/15/m1559/m1559_thumb.jpg

Use readPrincetonFile to create a MATLAB variable named vertexList that contains the vertices of the points in a point cloud file.  Note that this MATLAB function is in the cnvPrincetonShapeToPtCloud directory.  Example:  
```
[vertexList, minW, maxW, minH, maxH, minD, maxD] = readPrincetonFile('pt1559.ptcld')
```

Run MinDist or QuotaBAlanced algorithm using the vertexList variable. Example:  
```
algMinDist(vertexList, false, false) 
```
or 
```
algQuotaBalanced(vertexList, false, false)
```


## Motion Illuminations

# Limitations

# Getting the Source

# Executing this Software
