/*
 *  common.m
 *  cfxr
 *
 *  Created by Joachim Bengtsson on 2008-05-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */
#import "common.h"

float frnd(float range)
{
	return (float)rnd(10000)/10000*range;
}