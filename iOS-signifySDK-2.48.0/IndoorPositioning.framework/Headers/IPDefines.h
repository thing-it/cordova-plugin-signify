/*
 * (c) Philips Lighting, 2018.
 *   All rights reserved.
 */

#ifndef IPDEFINES_H
#define IPDEFINES_H

#if defined(__cplusplus)
#define IP_EXPORT extern "C" __attribute__((visibility ("default")))
#else
#define IP_EXPORT extern __attribute__((visibility ("default")))
#endif

#endif
