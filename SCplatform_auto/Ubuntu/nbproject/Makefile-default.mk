#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=cof
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=
else
COMPARISON_BUILD=
endif

ifdef SUB_IMAGE_ADDRESS

else
SUB_IMAGE_ADDRESS_COMMAND=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=SCpa.asm pauses_20MHz.asm TM1621Recognize.asm TM1621LCD.asm RTCTime.asm EEPROM.asm UART.asm RTCEEPROM.asm

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/SCpa.o ${OBJECTDIR}/pauses_20MHz.o ${OBJECTDIR}/TM1621Recognize.o ${OBJECTDIR}/TM1621LCD.o ${OBJECTDIR}/RTCTime.o ${OBJECTDIR}/EEPROM.o ${OBJECTDIR}/UART.o ${OBJECTDIR}/RTCEEPROM.o
POSSIBLE_DEPFILES=${OBJECTDIR}/SCpa.o.d ${OBJECTDIR}/pauses_20MHz.o.d ${OBJECTDIR}/TM1621Recognize.o.d ${OBJECTDIR}/TM1621LCD.o.d ${OBJECTDIR}/RTCTime.o.d ${OBJECTDIR}/EEPROM.o.d ${OBJECTDIR}/UART.o.d ${OBJECTDIR}/RTCEEPROM.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/SCpa.o ${OBJECTDIR}/pauses_20MHz.o ${OBJECTDIR}/TM1621Recognize.o ${OBJECTDIR}/TM1621LCD.o ${OBJECTDIR}/RTCTime.o ${OBJECTDIR}/EEPROM.o ${OBJECTDIR}/UART.o ${OBJECTDIR}/RTCEEPROM.o

# Source Files
SOURCEFILES=SCpa.asm pauses_20MHz.asm TM1621Recognize.asm TM1621LCD.asm RTCTime.asm EEPROM.asm UART.asm RTCEEPROM.asm


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk dist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=16f887
MP_LINKER_DEBUG_OPTION=-r=ROM@0x1F00:0x1FFE -r=RAM@SHARE:0x70:0x70 -r=RAM@SHARE:0xF0:0xF0 -r=RAM@SHARE:0x170:0x170 -r=RAM@GPR:0x1E5:0x1EF -r=RAM@SHARE:0x1F0:0x1F0
# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/SCpa.o: SCpa.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/SCpa.o.d 
	@${RM} ${OBJECTDIR}/SCpa.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/SCpa.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/SCpa.lst\\\" -e\\\"${OBJECTDIR}/SCpa.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/SCpa.o\\\" \\\"SCpa.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/SCpa.o"
	@${FIXDEPS} "${OBJECTDIR}/SCpa.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/pauses_20MHz.o: pauses_20MHz.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/pauses_20MHz.o.d 
	@${RM} ${OBJECTDIR}/pauses_20MHz.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/pauses_20MHz.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/pauses_20MHz.lst\\\" -e\\\"${OBJECTDIR}/pauses_20MHz.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/pauses_20MHz.o\\\" \\\"pauses_20MHz.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/pauses_20MHz.o"
	@${FIXDEPS} "${OBJECTDIR}/pauses_20MHz.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/TM1621Recognize.o: TM1621Recognize.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/TM1621Recognize.o.d 
	@${RM} ${OBJECTDIR}/TM1621Recognize.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/TM1621Recognize.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/TM1621Recognize.lst\\\" -e\\\"${OBJECTDIR}/TM1621Recognize.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/TM1621Recognize.o\\\" \\\"TM1621Recognize.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/TM1621Recognize.o"
	@${FIXDEPS} "${OBJECTDIR}/TM1621Recognize.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/TM1621LCD.o: TM1621LCD.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/TM1621LCD.o.d 
	@${RM} ${OBJECTDIR}/TM1621LCD.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/TM1621LCD.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/TM1621LCD.lst\\\" -e\\\"${OBJECTDIR}/TM1621LCD.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/TM1621LCD.o\\\" \\\"TM1621LCD.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/TM1621LCD.o"
	@${FIXDEPS} "${OBJECTDIR}/TM1621LCD.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/RTCTime.o: RTCTime.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/RTCTime.o.d 
	@${RM} ${OBJECTDIR}/RTCTime.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/RTCTime.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/RTCTime.lst\\\" -e\\\"${OBJECTDIR}/RTCTime.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/RTCTime.o\\\" \\\"RTCTime.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/RTCTime.o"
	@${FIXDEPS} "${OBJECTDIR}/RTCTime.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/EEPROM.o: EEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/EEPROM.o.d 
	@${RM} ${OBJECTDIR}/EEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/EEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/EEPROM.lst\\\" -e\\\"${OBJECTDIR}/EEPROM.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/EEPROM.o\\\" \\\"EEPROM.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/EEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/EEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/UART.o: UART.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/UART.o.d 
	@${RM} ${OBJECTDIR}/UART.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/UART.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/UART.lst\\\" -e\\\"${OBJECTDIR}/UART.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/UART.o\\\" \\\"UART.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/UART.o"
	@${FIXDEPS} "${OBJECTDIR}/UART.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/RTCEEPROM.o: RTCEEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/RTCEEPROM.o.d 
	@${RM} ${OBJECTDIR}/RTCEEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/RTCEEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PK3=1 -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/RTCEEPROM.lst\\\" -e\\\"${OBJECTDIR}/RTCEEPROM.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/RTCEEPROM.o\\\" \\\"RTCEEPROM.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/RTCEEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/RTCEEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
else
${OBJECTDIR}/SCpa.o: SCpa.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/SCpa.o.d 
	@${RM} ${OBJECTDIR}/SCpa.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/SCpa.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/SCpa.lst\\\" -e\\\"${OBJECTDIR}/SCpa.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/SCpa.o\\\" \\\"SCpa.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/SCpa.o"
	@${FIXDEPS} "${OBJECTDIR}/SCpa.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/pauses_20MHz.o: pauses_20MHz.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/pauses_20MHz.o.d 
	@${RM} ${OBJECTDIR}/pauses_20MHz.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/pauses_20MHz.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/pauses_20MHz.lst\\\" -e\\\"${OBJECTDIR}/pauses_20MHz.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/pauses_20MHz.o\\\" \\\"pauses_20MHz.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/pauses_20MHz.o"
	@${FIXDEPS} "${OBJECTDIR}/pauses_20MHz.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/TM1621Recognize.o: TM1621Recognize.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/TM1621Recognize.o.d 
	@${RM} ${OBJECTDIR}/TM1621Recognize.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/TM1621Recognize.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/TM1621Recognize.lst\\\" -e\\\"${OBJECTDIR}/TM1621Recognize.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/TM1621Recognize.o\\\" \\\"TM1621Recognize.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/TM1621Recognize.o"
	@${FIXDEPS} "${OBJECTDIR}/TM1621Recognize.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/TM1621LCD.o: TM1621LCD.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/TM1621LCD.o.d 
	@${RM} ${OBJECTDIR}/TM1621LCD.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/TM1621LCD.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/TM1621LCD.lst\\\" -e\\\"${OBJECTDIR}/TM1621LCD.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/TM1621LCD.o\\\" \\\"TM1621LCD.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/TM1621LCD.o"
	@${FIXDEPS} "${OBJECTDIR}/TM1621LCD.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/RTCTime.o: RTCTime.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/RTCTime.o.d 
	@${RM} ${OBJECTDIR}/RTCTime.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/RTCTime.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/RTCTime.lst\\\" -e\\\"${OBJECTDIR}/RTCTime.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/RTCTime.o\\\" \\\"RTCTime.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/RTCTime.o"
	@${FIXDEPS} "${OBJECTDIR}/RTCTime.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/EEPROM.o: EEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/EEPROM.o.d 
	@${RM} ${OBJECTDIR}/EEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/EEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/EEPROM.lst\\\" -e\\\"${OBJECTDIR}/EEPROM.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/EEPROM.o\\\" \\\"EEPROM.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/EEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/EEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/UART.o: UART.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/UART.o.d 
	@${RM} ${OBJECTDIR}/UART.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/UART.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/UART.lst\\\" -e\\\"${OBJECTDIR}/UART.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/UART.o\\\" \\\"UART.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/UART.o"
	@${FIXDEPS} "${OBJECTDIR}/UART.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/RTCEEPROM.o: RTCEEPROM.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/RTCEEPROM.o.d 
	@${RM} ${OBJECTDIR}/RTCEEPROM.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/RTCEEPROM.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION) -u  -l\\\"${OBJECTDIR}/RTCEEPROM.lst\\\" -e\\\"${OBJECTDIR}/RTCEEPROM.err\\\" $(ASM_OPTIONS)    -o\\\"${OBJECTDIR}/RTCEEPROM.o\\\" \\\"RTCEEPROM.asm\\\" 
	@${DEP_GEN} -d "${OBJECTDIR}/RTCEEPROM.o"
	@${FIXDEPS} "${OBJECTDIR}/RTCEEPROM.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w -x -u_DEBUG -z__ICD2RAM=1 -m"$(BINDIR_)$(TARGETBASE).map" -w -l"."   -z__MPLAB_BUILD=1  -z__MPLAB_DEBUG=1 -z__MPLAB_DEBUGGER_PK3=1 $(MP_LINKER_DEBUG_OPTION) -odist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
else
dist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w  -m"$(BINDIR_)$(TARGETBASE).map" -w -l"."   -z__MPLAB_BUILD=1  -odist/${CND_CONF}/${IMAGE_TYPE}/Ubuntu.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/default
	${RM} -r dist/default

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell "${PATH_TO_IDE_BIN}"mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
