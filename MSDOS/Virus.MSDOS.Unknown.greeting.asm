                                           
;  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;  쿒reeting Assembly Code (D86 Debug Used) �
;  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
                                           
0100 E9 EC 07                JMP 08EF
0103 42                      INC DX
0104 41                      INC CX
0105 0E                      PUSH CS
0106 01 CD                   ADD BP,CX
0108 21 B8 00 4C             AND W[BX+SI+04C00],DI
010C CD 21                   INT 021                ; Dos Functions
010E 48                      DEC AX
010F 65 6C                   REPC INSB
0111 6C                      INSB
0112 6F                      OUTSW
0113 20 77 6F                AND B[BX+06F],DH
0116 72 6C                   JB 0184
0118 64 2E 2E 2E 0A 0D       REPNC CS CS CS OR CL,B[DI]
011E 24 90                   AND AL,090
0120 90                      NOP
0121 90                      NOP
0122 90                      NOP
0123 90                      NOP
0124 90                      NOP
0125 90                      NOP
0126 90                      NOP
0127 90                      NOP
0128 90                      NOP
0129 90                      NOP
012A 90                      NOP
012B 90                      NOP
012C 90                      NOP
012D 90                      NOP
012E 90                      NOP
012F 90                      NOP
0130 90                      NOP
0131 90                      NOP
0132 90                      NOP
0133 90                      NOP
0134 90                      NOP
0135 90                      NOP
0136 90                      NOP
0137 90                      NOP
0138 90                      NOP
0139 90                      NOP
013A 90                      NOP
013B 90                      NOP
013C 90                      NOP
013D 90                      NOP
013E 90                      NOP
013F 90                      NOP
0140 90                      NOP
0141 90                      NOP
0142 90                      NOP
0143 90                      NOP
0144 90                      NOP
0145 90                      NOP
0146 90                      NOP
0147 90                      NOP
0148 90                      NOP
0149 90                      NOP
014A 90                      NOP
014B 90                      NOP
014C 90                      NOP
014D 90                      NOP
014E 90                      NOP
014F 90                      NOP
0150 90                      NOP
0151 90                      NOP
0152 90                      NOP
0153 90                      NOP
0154 90                      NOP
0155 90                      NOP
0156 90                      NOP
0157 90                      NOP
0158 90                      NOP
0159 90                      NOP
015A 90                      NOP
015B 90                      NOP
015C 90                      NOP
015D 90                      NOP
015E 90                      NOP
015F 90                      NOP
0160 90                      NOP
0161 90                      NOP
0162 90                      NOP
0163 90                      NOP
0164 90                      NOP
0165 90                      NOP
0166 90                      NOP
0167 90                      NOP
0168 90                      NOP
0169 90                      NOP
016A 90                      NOP
016B 90                      NOP
016C 90                      NOP
016D 90                      NOP
016E 90                      NOP
016F 90                      NOP
0170 90                      NOP
0171 90                      NOP
0172 90                      NOP
0173 90                      NOP
0174 90                      NOP
0175 90                      NOP
0176 90                      NOP
0177 90                      NOP
0178 90                      NOP
0179 90                      NOP
017A 90                      NOP
017B 90                      NOP
017C 90                      NOP
017D 90                      NOP
017E 90                      NOP
017F 90                      NOP
0180 90                      NOP
0181 90                      NOP
0182 90                      NOP
0183 90                      NOP
0184 90                      NOP
0185 90                      NOP
0186 90                      NOP
0187 90                      NOP
0188 90                      NOP
0189 90                      NOP
018A 90                      NOP
018B 90                      NOP
018C 90                      NOP
018D 90                      NOP
018E 90                      NOP
018F 90                      NOP
0190 90                      NOP
0191 90                      NOP
0192 90                      NOP
0193 90                      NOP
0194 90                      NOP
0195 90                      NOP
0196 90                      NOP
0197 90                      NOP
0198 90                      NOP
0199 90                      NOP
019A 90                      NOP
019B 90                      NOP
019C 90                      NOP
019D 90                      NOP
019E 90                      NOP
019F 90                      NOP
01A0 90                      NOP
01A1 90                      NOP
01A2 90                      NOP
01A3 90                      NOP
01A4 90                      NOP
01A5 90                      NOP
01A6 90                      NOP
01A7 90                      NOP
01A8 90                      NOP
01A9 90                      NOP
01AA 90                      NOP
01AB 90                      NOP
01AC 90                      NOP
01AD 90                      NOP
01AE 90                      NOP
01AF 90                      NOP
01B0 90                      NOP
01B1 90                      NOP
01B2 90                      NOP
01B3 90                      NOP
01B4 90                      NOP
01B5 90                      NOP
01B6 90                      NOP
01B7 90                      NOP
01B8 90                      NOP
01B9 90                      NOP
01BA 90                      NOP
01BB 90                      NOP
01BC 90                      NOP
01BD 90                      NOP
01BE 90                      NOP
01BF 90                      NOP
01C0 90                      NOP
01C1 90                      NOP
01C2 90                      NOP
01C3 90                      NOP
01C4 90                      NOP
01C5 90                      NOP
01C6 90                      NOP
01C7 90                      NOP
01C8 90                      NOP
01C9 90                      NOP
01CA 90                      NOP
01CB 90                      NOP
01CC 90                      NOP
01CD 90                      NOP
01CE 90                      NOP
01CF 90                      NOP
01D0 90                      NOP
01D1 90                      NOP
01D2 90                      NOP
01D3 90                      NOP
01D4 90                      NOP
01D5 90                      NOP
01D6 90                      NOP
01D7 90                      NOP
01D8 90                      NOP
01D9 90                      NOP
01DA 90                      NOP
01DB 90                      NOP
01DC 90                      NOP
01DD 90                      NOP
01DE 90                      NOP
01DF 90                      NOP
01E0 90                      NOP
01E1 90                      NOP
01E2 90                      NOP
01E3 90                      NOP
01E4 90                      NOP
01E5 90                      NOP
01E6 90                      NOP
01E7 90                      NOP
01E8 90                      NOP
01E9 90                      NOP
01EA 90                      NOP
01EB 90                      NOP
01EC 90                      NOP
01ED 90                      NOP
01EE 90                      NOP
01EF 90                      NOP
01F0 90                      NOP
01F1 90                      NOP
01F2 90                      NOP
01F3 90                      NOP
01F4 90                      NOP
01F5 90                      NOP
01F6 90                      NOP
01F7 90                      NOP
01F8 90                      NOP
01F9 90                      NOP
01FA 90                      NOP
01FB 90                      NOP
01FC 90                      NOP
01FD 90                      NOP
01FE 90                      NOP
01FF 90                      NOP
0200 90                      NOP
0201 90                      NOP
0202 90                      NOP
0203 90                      NOP
0204 90                      NOP
0205 90                      NOP
0206 90                      NOP
0207 90                      NOP
0208 90                      NOP
0209 90                      NOP
020A 90                      NOP
020B 90                      NOP
020C 90                      NOP
020D 90                      NOP
020E 90                      NOP
020F 90                      NOP
0210 90                      NOP
0211 90                      NOP
0212 90                      NOP
0213 90                      NOP
0214 90                      NOP
0215 90                      NOP
0216 90                      NOP
0217 90                      NOP
0218 90                      NOP
0219 90                      NOP
021A 90                      NOP
021B 90                      NOP
021C 90                      NOP
021D 90                      NOP
021E 90                      NOP
021F 90                      NOP
0220 90                      NOP
0221 90                      NOP
0222 90                      NOP
0223 90                      NOP
0224 90                      NOP
0225 90                      NOP
0226 90                      NOP
0227 90                      NOP
0228 90                      NOP
0229 90                      NOP
022A 90                      NOP
022B 90                      NOP
022C 90                      NOP
022D 90                      NOP
022E 90                      NOP
022F 90                      NOP
0230 90                      NOP
0231 90                      NOP
0232 90                      NOP
0233 90                      NOP
0234 90                      NOP
0235 90                      NOP
0236 90                      NOP
0237 90                      NOP
0238 90                      NOP
0239 90                      NOP
023A 90                      NOP
023B 90                      NOP
023C 90                      NOP
023D 90                      NOP
023E 90                      NOP
023F 90                      NOP
0240 90                      NOP
0241 90                      NOP
0242 90                      NOP
0243 90                      NOP
0244 90                      NOP
0245 90                      NOP
0246 90                      NOP
0247 90                      NOP
0248 90                      NOP
0249 90                      NOP
024A 90                      NOP
024B 90                      NOP
024C 90                      NOP
024D 90                      NOP
024E 90                      NOP
024F 90                      NOP
0250 90                      NOP
0251 90                      NOP
0252 90                      NOP
0253 90                      NOP
0254 90                      NOP
0255 90                      NOP
0256 90                      NOP
0257 90                      NOP
0258 90                      NOP
0259 90                      NOP
025A 90                      NOP
025B 90                      NOP
025C 90                      NOP
025D 90                      NOP
025E 90                      NOP
025F 90                      NOP
0260 90                      NOP
0261 90                      NOP
0262 90                      NOP
0263 90                      NOP
0264 90                      NOP
0265 90                      NOP
0266 90                      NOP
0267 90                      NOP
0268 90                      NOP
0269 90                      NOP
026A 90                      NOP
026B 90                      NOP
026C 90                      NOP
026D 90                      NOP
026E 90                      NOP
026F 90                      NOP
0270 90                      NOP
0271 90                      NOP
0272 90                      NOP
0273 90                      NOP
0274 90                      NOP
0275 90                      NOP
0276 90                      NOP
0277 90                      NOP
0278 90                      NOP
0279 90                      NOP
027A 90                      NOP
027B 90                      NOP
027C 90                      NOP
027D 90                      NOP
027E 90                      NOP
027F 90                      NOP
0280 90                      NOP
0281 90                      NOP
0282 90                      NOP
0283 90                      NOP
0284 90                      NOP
0285 90                      NOP
0286 90                      NOP
0287 90                      NOP
0288 90                      NOP
0289 90                      NOP
028A 90                      NOP
028B 90                      NOP
028C 90                      NOP
028D 90                      NOP
028E 90                      NOP
028F 90                      NOP
0290 90                      NOP
0291 90                      NOP
0292 90                      NOP
0293 90                      NOP
0294 90                      NOP
0295 90                      NOP
0296 90                      NOP
0297 90                      NOP
0298 90                      NOP
0299 90                      NOP
029A 90                      NOP
029B 90                      NOP
029C 90                      NOP
029D 90                      NOP
029E 90                      NOP
029F 90                      NOP
02A0 90                      NOP
02A1 90                      NOP
02A2 90                      NOP
02A3 90                      NOP
02A4 90                      NOP
02A5 90                      NOP
02A6 90                      NOP
02A7 90                      NOP
02A8 90                      NOP
02A9 90                      NOP
02AA 90                      NOP
02AB 90                      NOP
02AC 90                      NOP
02AD 90                      NOP
02AE 90                      NOP
02AF 90                      NOP
02B0 90                      NOP
02B1 90                      NOP
02B2 90                      NOP
02B3 90                      NOP
02B4 90                      NOP
02B5 90                      NOP
02B6 90                      NOP
02B7 90                      NOP
02B8 90                      NOP
02B9 90                      NOP
02BA 90                      NOP
02BB 90                      NOP
02BC 90                      NOP
02BD 90                      NOP
02BE 90                      NOP
02BF 90                      NOP
02C0 90                      NOP
02C1 90                      NOP
02C2 90                      NOP
02C3 90                      NOP
02C4 90                      NOP
02C5 90                      NOP
02C6 90                      NOP
02C7 90                      NOP
02C8 90                      NOP
02C9 90                      NOP
02CA 90                      NOP
02CB 90                      NOP
02CC 90                      NOP
02CD 90                      NOP
02CE 90                      NOP
02CF 90                      NOP
02D0 90                      NOP
02D1 90                      NOP
02D2 90                      NOP
02D3 90                      NOP
02D4 90                      NOP
02D5 90                      NOP
02D6 90                      NOP
02D7 90                      NOP
02D8 90                      NOP
02D9 90                      NOP
02DA 90                      NOP
02DB 90                      NOP
02DC 90                      NOP
02DD 90                      NOP
02DE 90                      NOP
02DF 90                      NOP
02E0 90                      NOP
02E1 90                      NOP
02E2 90                      NOP
02E3 90                      NOP
02E4 90                      NOP
02E5 90                      NOP
02E6 90                      NOP
02E7 90                      NOP
02E8 90                      NOP
02E9 90                      NOP
02EA 90                      NOP
02EB 90                      NOP
02EC 90                      NOP
02ED 90                      NOP
02EE 90                      NOP
02EF 90                      NOP
02F0 90                      NOP
02F1 90                      NOP
02F2 90                      NOP
02F3 90                      NOP
02F4 90                      NOP
02F5 90                      NOP
02F6 90                      NOP
02F7 90                      NOP
02F8 90                      NOP
02F9 90                      NOP
02FA 90                      NOP
02FB 90                      NOP
02FC 90                      NOP
02FD 90                      NOP
02FE 90                      NOP
02FF 90                      NOP
0300 90                      NOP
0301 90                      NOP
0302 90                      NOP
0303 90                      NOP
0304 90                      NOP
0305 90                      NOP
0306 90                      NOP
0307 90                      NOP
0308 90                      NOP
0309 90                      NOP
030A 90                      NOP
030B 90                      NOP
030C 90                      NOP
030D 90                      NOP
030E 90                      NOP
030F 90                      NOP
0310 90                      NOP
0311 90                      NOP
0312 90                      NOP
0313 90                      NOP
0314 90                      NOP
0315 90                      NOP
0316 90                      NOP
0317 90                      NOP
0318 90                      NOP
0319 90                      NOP
031A 90                      NOP
031B 90                      NOP
031C 90                      NOP
031D 90                      NOP
031E 90                      NOP
031F 90                      NOP
0320 90                      NOP
0321 90                      NOP
0322 90                      NOP
0323 90                      NOP
0324 90                      NOP
0325 90                      NOP
0326 90                      NOP
0327 90                      NOP
0328 90                      NOP
0329 90                      NOP
032A 90                      NOP
032B 90                      NOP
032C 90                      NOP
032D 90                      NOP
032E 90                      NOP
032F 90                      NOP
0330 90                      NOP
0331 90                      NOP
0332 90                      NOP
0333 90                      NOP
0334 90                      NOP
0335 90                      NOP
0336 90                      NOP
0337 90                      NOP
0338 90                      NOP
0339 90                      NOP
033A 90                      NOP
033B 90                      NOP
033C 90                      NOP
033D 90                      NOP
033E 90                      NOP
033F 90                      NOP
0340 90                      NOP
0341 90                      NOP
0342 90                      NOP
0343 90                      NOP
0344 90                      NOP
0345 90                      NOP
0346 90                      NOP
0347 90                      NOP
0348 90                      NOP
0349 90                      NOP
034A 90                      NOP
034B 90                      NOP
034C 90                      NOP
034D 90                      NOP
034E 90                      NOP
034F 90                      NOP
0350 90                      NOP
0351 90                      NOP
0352 90                      NOP
0353 90                      NOP
0354 90                      NOP
0355 90                      NOP
0356 90                      NOP
0357 90                      NOP
0358 90                      NOP
0359 90                      NOP
035A 90                      NOP
035B 90                      NOP
035C 90                      NOP
035D 90                      NOP
035E 90                      NOP
035F 90                      NOP
0360 90                      NOP
0361 90                      NOP
0362 90                      NOP
0363 90                      NOP
0364 90                      NOP
0365 90                      NOP
0366 90                      NOP
0367 90                      NOP
0368 90                      NOP
0369 90                      NOP
036A 90                      NOP
036B 90                      NOP
036C 90                      NOP
036D 90                      NOP
036E 90                      NOP
036F 90                      NOP
0370 90                      NOP
0371 90                      NOP
0372 90                      NOP
0373 90                      NOP
0374 90                      NOP
0375 90                      NOP
0376 90                      NOP
0377 90                      NOP
0378 90                      NOP
0379 90                      NOP
037A 90                      NOP
037B 90                      NOP
037C 90                      NOP
037D 90                      NOP
037E 90                      NOP
037F 90                      NOP
0380 90                      NOP
0381 90                      NOP
0382 90                      NOP
0383 90                      NOP
0384 90                      NOP
0385 90                      NOP
0386 90                      NOP
0387 90                      NOP
0388 90                      NOP
0389 90                      NOP
038A 90                      NOP
038B 90                      NOP
038C 90                      NOP
038D 90                      NOP
038E 90                      NOP
038F 90                      NOP
0390 90                      NOP
0391 90                      NOP
0392 90                      NOP
0393 90                      NOP
0394 90                      NOP
0395 90                      NOP
0396 90                      NOP
0397 90                      NOP
0398 90                      NOP
0399 90                      NOP
039A 90                      NOP
039B 90                      NOP
039C 90                      NOP
039D 90                      NOP
039E 90                      NOP
039F 90                      NOP
03A0 90                      NOP
03A1 90                      NOP
03A2 90                      NOP
03A3 90                      NOP
03A4 90                      NOP
03A5 90                      NOP
03A6 90                      NOP
03A7 90                      NOP
03A8 90                      NOP
03A9 90                      NOP
03AA 90                      NOP
03AB 90                      NOP
03AC 90                      NOP
03AD 90                      NOP
03AE 90                      NOP
03AF 90                      NOP
03B0 90                      NOP
03B1 90                      NOP
03B2 90                      NOP
03B3 90                      NOP
03B4 90                      NOP
03B5 90                      NOP
03B6 90                      NOP
03B7 90                      NOP
03B8 90                      NOP
03B9 90                      NOP
03BA 90                      NOP
03BB 90                      NOP
03BC 90                      NOP
03BD 90                      NOP
03BE 90                      NOP
03BF 90                      NOP
03C0 90                      NOP
03C1 90                      NOP
03C2 90                      NOP
03C3 90                      NOP
03C4 90                      NOP
03C5 90                      NOP
03C6 90                      NOP
03C7 90                      NOP
03C8 90                      NOP
03C9 90                      NOP
03CA 90                      NOP
03CB 90                      NOP
03CC 90                      NOP
03CD 90                      NOP
03CE 90                      NOP
03CF 90                      NOP
03D0 90                      NOP
03D1 90                      NOP
03D2 90                      NOP
03D3 90                      NOP
03D4 90                      NOP
03D5 90                      NOP
03D6 90                      NOP
03D7 90                      NOP
03D8 90                      NOP
03D9 90                      NOP
03DA 90                      NOP
03DB 90                      NOP
03DC 90                      NOP
03DD 90                      NOP
03DE 90                      NOP
03DF 90                      NOP
03E0 90                      NOP
03E1 90                      NOP
03E2 90                      NOP
03E3 90                      NOP
03E4 90                      NOP
03E5 90                      NOP
03E6 90                      NOP
03E7 90                      NOP
03E8 90                      NOP
03E9 90                      NOP
03EA 90                      NOP
03EB 90                      NOP
03EC 90                      NOP
03ED 90                      NOP
03EE 90                      NOP
03EF 90                      NOP
03F0 90                      NOP
03F1 90                      NOP
03F2 90                      NOP
03F3 90                      NOP
03F4 90                      NOP
03F5 90                      NOP
03F6 90                      NOP
03F7 90                      NOP
03F8 90                      NOP
03F9 90                      NOP
03FA 90                      NOP
03FB 90                      NOP
03FC 90                      NOP
03FD 90                      NOP
03FE 90                      NOP
03FF 90                      NOP
0400 90                      NOP
0401 90                      NOP
0402 90                      NOP
0403 90                      NOP
0404 90                      NOP
0405 90                      NOP
0406 90                      NOP
0407 90                      NOP
0408 90                      NOP
0409 90                      NOP
040A 90                      NOP
040B 90                      NOP
040C 90                      NOP
040D 90                      NOP
040E 90                      NOP
040F 90                      NOP
0410 90                      NOP
0411 90                      NOP
0412 90                      NOP
0413 90                      NOP
0414 90                      NOP
0415 90                      NOP
0416 90                      NOP
0417 90                      NOP
0418 90                      NOP
0419 90                      NOP
041A 90                      NOP
041B 90                      NOP
041C 90                      NOP
041D 90                      NOP
041E 90                      NOP
041F 90                      NOP
0420 90                      NOP
0421 90                      NOP
0422 90                      NOP
0423 90                      NOP
0424 90                      NOP
0425 90                      NOP
0426 90                      NOP
0427 90                      NOP
0428 90                      NOP
0429 90                      NOP
042A 90                      NOP
042B 90                      NOP
042C 90                      NOP
042D 90                      NOP
042E 90                      NOP
042F 90                      NOP
0430 90                      NOP
0431 90                      NOP
0432 90                      NOP
0433 90                      NOP
0434 90                      NOP
0435 90                      NOP
0436 90                      NOP
0437 90                      NOP
0438 90                      NOP
0439 90                      NOP
043A 90                      NOP
043B 90                      NOP
043C 90                      NOP
043D 90                      NOP
043E 90                      NOP
043F 90                      NOP
0440 90                      NOP
0441 90                      NOP
0442 90                      NOP
0443 90                      NOP
0444 90                      NOP
0445 90                      NOP
0446 90                      NOP
0447 90                      NOP
0448 90                      NOP
0449 90                      NOP
044A 90                      NOP
044B 90                      NOP
044C 90                      NOP
044D 90                      NOP
044E 90                      NOP
044F 90                      NOP
0450 90                      NOP
0451 90                      NOP
0452 90                      NOP
0453 90                      NOP
0454 90                      NOP
0455 90                      NOP
0456 90                      NOP
0457 90                      NOP
0458 90                      NOP
0459 90                      NOP
045A 90                      NOP
045B 90                      NOP
045C 90                      NOP
045D 90                      NOP
045E 90                      NOP
045F 90                      NOP
0460 90                      NOP
0461 90                      NOP
0462 90                      NOP
0463 90                      NOP
0464 90                      NOP
0465 90                      NOP
0466 90                      NOP
0467 90                      NOP
0468 90                      NOP
0469 90                      NOP
046A 90                      NOP
046B 90                      NOP
046C 90                      NOP
046D 90                      NOP
046E 90                      NOP
046F 90                      NOP
0470 90                      NOP
0471 90                      NOP
0472 90                      NOP
0473 90                      NOP
0474 90                      NOP
0475 90                      NOP
0476 90                      NOP
0477 90                      NOP
0478 90                      NOP
0479 90                      NOP
047A 90                      NOP
047B 90                      NOP
047C 90                      NOP
047D 90                      NOP
047E 90                      NOP
047F 90                      NOP
0480 90                      NOP
0481 90                      NOP
0482 90                      NOP
0483 90                      NOP
0484 90                      NOP
0485 90                      NOP
0486 90                      NOP
0487 90                      NOP
0488 90                      NOP
0489 90                      NOP
048A 90                      NOP
048B 90                      NOP
048C 90                      NOP
048D 90                      NOP
048E 90                      NOP
048F 90                      NOP
0490 90                      NOP
0491 90                      NOP
0492 90                      NOP
0493 90                      NOP
0494 90                      NOP
0495 90                      NOP
0496 90                      NOP
0497 90                      NOP
0498 90                      NOP
0499 90                      NOP
049A 90                      NOP
049B 90                      NOP
049C 90                      NOP
049D 90                      NOP
049E 90                      NOP
049F 90                      NOP
04A0 90                      NOP
04A1 90                      NOP
04A2 90                      NOP
04A3 90                      NOP
04A4 90                      NOP
04A5 90                      NOP
04A6 90                      NOP
04A7 90                      NOP
04A8 90                      NOP
04A9 90                      NOP
04AA 90                      NOP
04AB 90                      NOP
04AC 90                      NOP
04AD 90                      NOP
04AE 90                      NOP
04AF 90                      NOP
04B0 90                      NOP
04B1 90                      NOP
04B2 90                      NOP
04B3 90                      NOP
04B4 90                      NOP
04B5 90                      NOP
04B6 90                      NOP
04B7 90                      NOP
04B8 90                      NOP
04B9 90                      NOP
04BA 90                      NOP
04BB 90                      NOP
04BC 90                      NOP
04BD 90                      NOP
04BE 90                      NOP
04BF 90                      NOP
04C0 90                      NOP
04C1 90                      NOP
04C2 90                      NOP
04C3 90                      NOP
04C4 90                      NOP
04C5 90                      NOP
04C6 90                      NOP
04C7 90                      NOP
04C8 90                      NOP
04C9 90                      NOP
04CA 90                      NOP
04CB 90                      NOP
04CC 90                      NOP
04CD 90                      NOP
04CE 90                      NOP
04CF 90                      NOP
04D0 90                      NOP
04D1 90                      NOP
04D2 90                      NOP
04D3 90                      NOP
04D4 90                      NOP
04D5 90                      NOP
04D6 90                      NOP
04D7 90                      NOP
04D8 90                      NOP
04D9 90                      NOP
04DA 90                      NOP
04DB 90                      NOP
04DC 90                      NOP
04DD 90                      NOP
04DE 90                      NOP
04DF 90                      NOP
04E0 90                      NOP
04E1 90                      NOP
04E2 90                      NOP
04E3 90                      NOP
04E4 90                      NOP
04E5 90                      NOP
04E6 90                      NOP
04E7 90                      NOP
04E8 90                      NOP
04E9 90                      NOP
04EA 90                      NOP
04EB 90                      NOP
04EC 90                      NOP
04ED 90                      NOP
04EE 90                      NOP
04EF 90                      NOP
04F0 90                      NOP
04F1 90                      NOP
04F2 90                      NOP
04F3 90                      NOP
04F4 90                      NOP
04F5 90                      NOP
04F6 90                      NOP
04F7 90                      NOP
04F8 90                      NOP
04F9 90                      NOP
04FA 90                      NOP
04FB 90                      NOP
04FC 90                      NOP
04FD 90                      NOP
04FE 90                      NOP
04FF 90                      NOP
0500 90                      NOP
0501 90                      NOP
0502 90                      NOP
0503 90                      NOP
0504 90                      NOP
0505 90                      NOP
0506 90                      NOP
0507 90                      NOP
0508 90                      NOP
0509 90                      NOP
050A 90                      NOP
050B 90                      NOP
050C 90                      NOP
050D 90                      NOP
050E 90                      NOP
050F 90                      NOP
0510 90                      NOP
0511 90                      NOP
0512 90                      NOP
0513 90                      NOP
0514 90                      NOP
0515 90                      NOP
0516 90                      NOP
0517 90                      NOP
0518 90                      NOP
0519 90                      NOP
051A 90                      NOP
051B 90                      NOP
051C 90                      NOP
051D 90                      NOP
051E 90                      NOP
051F 90                      NOP
0520 90                      NOP
0521 90                      NOP
0522 90                      NOP
0523 90                      NOP
0524 90                      NOP
0525 90                      NOP
0526 90                      NOP
0527 90                      NOP
0528 90                      NOP
0529 90                      NOP
052A 90                      NOP
052B 90                      NOP
052C 90                      NOP
052D 90                      NOP
052E 90                      NOP
052F 90                      NOP
0530 90                      NOP
0531 90                      NOP
0532 90                      NOP
0533 90                      NOP
0534 90                      NOP
0535 90                      NOP
0536 90                      NOP
0537 90                      NOP
0538 90                      NOP
0539 90                      NOP
053A 90                      NOP
053B 90                      NOP
053C 90                      NOP
053D 90                      NOP
053E 90                      NOP
053F 90                      NOP
0540 90                      NOP
0541 90                      NOP
0542 90                      NOP
0543 90                      NOP
0544 90                      NOP
0545 90                      NOP
0546 90                      NOP
0547 90                      NOP
0548 90                      NOP
0549 90                      NOP
054A 90                      NOP
054B 90                      NOP
054C 90                      NOP
054D 90                      NOP
054E 90                      NOP
054F 90                      NOP
0550 90                      NOP
0551 90                      NOP
0552 90                      NOP
0553 90                      NOP
0554 90                      NOP
0555 90                      NOP
0556 90                      NOP
0557 90                      NOP
0558 90                      NOP
0559 90                      NOP
055A 90                      NOP
055B 90                      NOP
055C 90                      NOP
055D 90                      NOP
055E 90                      NOP
055F 90                      NOP
0560 90                      NOP
0561 90                      NOP
0562 90                      NOP
0563 90                      NOP
0564 90                      NOP
0565 90                      NOP
0566 90                      NOP
0567 90                      NOP
0568 90                      NOP
0569 90                      NOP
056A 90                      NOP
056B 90                      NOP
056C 90                      NOP
056D 90                      NOP
056E 90                      NOP
056F 90                      NOP
0570 90                      NOP
0571 90                      NOP
0572 90                      NOP
0573 90                      NOP
0574 90                      NOP
0575 90                      NOP
0576 90                      NOP
0577 90                      NOP
0578 90                      NOP
0579 90                      NOP
057A 90                      NOP
057B 90                      NOP
057C 90                      NOP
057D 90                      NOP
057E 90                      NOP
057F 90                      NOP
0580 90                      NOP
0581 90                      NOP
0582 90                      NOP
0583 90                      NOP
0584 90                      NOP
0585 90                      NOP
0586 90                      NOP
0587 90                      NOP
0588 90                      NOP
0589 90                      NOP
058A 90                      NOP
058B 90                      NOP
058C 90                      NOP
058D 90                      NOP
058E 90                      NOP
058F 90                      NOP
0590 90                      NOP
0591 90                      NOP
0592 90                      NOP
0593 90                      NOP
0594 90                      NOP
0595 90                      NOP
0596 90                      NOP
0597 90                      NOP
0598 90                      NOP
0599 90                      NOP
059A 90                      NOP
059B 90                      NOP
059C 90                      NOP
059D 90                      NOP
059E 90                      NOP
059F 90                      NOP
05A0 90                      NOP
05A1 90                      NOP
05A2 90                      NOP
05A3 90                      NOP
05A4 90                      NOP
05A5 90                      NOP
05A6 90                      NOP
05A7 90                      NOP
05A8 90                      NOP
05A9 90                      NOP
05AA 90                      NOP
05AB 90                      NOP
05AC 90                      NOP
05AD 90                      NOP
05AE 90                      NOP
05AF 90                      NOP
05B0 90                      NOP
05B1 90                      NOP
05B2 90                      NOP
05B3 90                      NOP
05B4 90                      NOP
05B5 90                      NOP
05B6 90                      NOP
05B7 90                      NOP
05B8 90                      NOP
05B9 90                      NOP
05BA 90                      NOP
05BB 90                      NOP
05BC 90                      NOP
05BD 90                      NOP
05BE 90                      NOP
05BF 90                      NOP
05C0 90                      NOP
05C1 90                      NOP
05C2 90                      NOP
05C3 90                      NOP
05C4 90                      NOP
05C5 90                      NOP
05C6 90                      NOP
05C7 90                      NOP
05C8 90                      NOP
05C9 90                      NOP
05CA 90                      NOP
05CB 90                      NOP
05CC 90                      NOP
05CD 90                      NOP
05CE 90                      NOP
05CF 90                      NOP
05D0 90                      NOP
05D1 90                      NOP
05D2 90                      NOP
05D3 90                      NOP
05D4 90                      NOP
05D5 90                      NOP
05D6 90                      NOP
05D7 90                      NOP
05D8 90                      NOP
05D9 90                      NOP
05DA 90                      NOP
05DB 90                      NOP
05DC 90                      NOP
05DD 90                      NOP
05DE 90                      NOP
05DF 90                      NOP
05E0 90                      NOP
05E1 90                      NOP
05E2 90                      NOP
05E3 90                      NOP
05E4 90                      NOP
05E5 90                      NOP
05E6 90                      NOP
05E7 90                      NOP
05E8 90                      NOP
05E9 90                      NOP
05EA 90                      NOP
05EB 90                      NOP
05EC 90                      NOP
05ED 90                      NOP
05EE 90                      NOP
05EF 90                      NOP
05F0 90                      NOP
05F1 90                      NOP
05F2 90                      NOP
05F3 90                      NOP
05F4 90                      NOP
05F5 90                      NOP
05F6 90                      NOP
05F7 90                      NOP
05F8 90                      NOP
05F9 90                      NOP
05FA 90                      NOP
05FB 90                      NOP
05FC 90                      NOP
05FD 90                      NOP
05FE 90                      NOP
05FF 90                      NOP
0600 90                      NOP
0601 90                      NOP
0602 90                      NOP
0603 90                      NOP
0604 90                      NOP
0605 90                      NOP
0606 90                      NOP
0607 90                      NOP
0608 90                      NOP
0609 90                      NOP
060A 90                      NOP
060B 90                      NOP
060C 90                      NOP
060D 90                      NOP
060E 90                      NOP
060F 90                      NOP
0610 90                      NOP
0611 90                      NOP
0612 90                      NOP
0613 90                      NOP
0614 90                      NOP
0615 90                      NOP
0616 90                      NOP
0617 90                      NOP
0618 90                      NOP
0619 90                      NOP
061A 90                      NOP
061B 90                      NOP
061C 90                      NOP
061D 90                      NOP
061E 90                      NOP
061F 90                      NOP
0620 90                      NOP
0621 90                      NOP
0622 90                      NOP
0623 90                      NOP
0624 90                      NOP
0625 90                      NOP
0626 90                      NOP
0627 90                      NOP
0628 90                      NOP
0629 90                      NOP
062A 90                      NOP
062B 90                      NOP
062C 90                      NOP
062D 90                      NOP
062E 90                      NOP
062F 90                      NOP
0630 90                      NOP
0631 90                      NOP
0632 90                      NOP
0633 90                      NOP
0634 90                      NOP
0635 90                      NOP
0636 90                      NOP
0637 90                      NOP
0638 90                      NOP
0639 90                      NOP
063A 90                      NOP
063B 90                      NOP
063C 90                      NOP
063D 90                      NOP
063E 90                      NOP
063F 90                      NOP
0640 90                      NOP
0641 90                      NOP
0642 90                      NOP
0643 90                      NOP
0644 90                      NOP
0645 90                      NOP
0646 90                      NOP
0647 90                      NOP
0648 90                      NOP
0649 90                      NOP
064A 90                      NOP
064B 90                      NOP
064C 90                      NOP
064D 90                      NOP
064E 90                      NOP
064F 90                      NOP
0650 90                      NOP
0651 90                      NOP
0652 90                      NOP
0653 90                      NOP
0654 90                      NOP
0655 90                      NOP
0656 90                      NOP
0657 90                      NOP
0658 90                      NOP
0659 90                      NOP
065A 90                      NOP
065B 90                      NOP
065C 90                      NOP
065D 90                      NOP
065E 90                      NOP
065F 90                      NOP
0660 90                      NOP
0661 90                      NOP
0662 90                      NOP
0663 90                      NOP
0664 90                      NOP
0665 90                      NOP
0666 90                      NOP
0667 90                      NOP
0668 90                      NOP
0669 90                      NOP
066A 90                      NOP
066B 90                      NOP
066C 90                      NOP
066D 90                      NOP
066E 90                      NOP
066F 90                      NOP
0670 90                      NOP
0671 90                      NOP
0672 90                      NOP
0673 90                      NOP
0674 90                      NOP
0675 90                      NOP
0676 90                      NOP
0677 90                      NOP
0678 90                      NOP
0679 90                      NOP
067A 90                      NOP
067B 90                      NOP
067C 90                      NOP
067D 90                      NOP
067E 90                      NOP
067F 90                      NOP
0680 90                      NOP
0681 90                      NOP
0682 90                      NOP
0683 90                      NOP
0684 90                      NOP
0685 90                      NOP
0686 90                      NOP
0687 90                      NOP
0688 90                      NOP
0689 90                      NOP
068A 90                      NOP
068B 90                      NOP
068C 90                      NOP
068D 90                      NOP
068E 90                      NOP
068F 90                      NOP
0690 90                      NOP
0691 90                      NOP
0692 90                      NOP
0693 90                      NOP
0694 90                      NOP
0695 90                      NOP
0696 90                      NOP
0697 90                      NOP
0698 90                      NOP
0699 90                      NOP
069A 90                      NOP
069B 90                      NOP
069C 90                      NOP
069D 90                      NOP
069E 90                      NOP
069F 90                      NOP
06A0 90                      NOP
06A1 90                      NOP
06A2 90                      NOP
06A3 90                      NOP
06A4 90                      NOP
06A5 90                      NOP
06A6 90                      NOP
06A7 90                      NOP
06A8 90                      NOP
06A9 90                      NOP
06AA 90                      NOP
06AB 90                      NOP
06AC 90                      NOP
06AD 90                      NOP
06AE 90                      NOP
06AF 90                      NOP
06B0 90                      NOP
06B1 90                      NOP
06B2 90                      NOP
06B3 90                      NOP
06B4 90                      NOP
06B5 90                      NOP
06B6 90                      NOP
06B7 90                      NOP
06B8 90                      NOP
06B9 90                      NOP
06BA 90                      NOP
06BB 90                      NOP
06BC 90                      NOP
06BD 90                      NOP
06BE 90                      NOP
06BF 90                      NOP
06C0 90                      NOP
06C1 90                      NOP
06C2 90                      NOP
06C3 90                      NOP
06C4 90                      NOP
06C5 90                      NOP
06C6 90                      NOP
06C7 90                      NOP
06C8 90                      NOP
06C9 90                      NOP
06CA 90                      NOP
06CB 90                      NOP
06CC 90                      NOP
06CD 90                      NOP
06CE 90                      NOP
06CF 90                      NOP
06D0 90                      NOP
06D1 90                      NOP
06D2 90                      NOP
06D3 90                      NOP
06D4 90                      NOP
06D5 90                      NOP
06D6 90                      NOP
06D7 90                      NOP
06D8 90                      NOP
06D9 90                      NOP
06DA 90                      NOP
06DB 90                      NOP
06DC 90                      NOP
06DD 90                      NOP
06DE 90                      NOP
06DF 90                      NOP
06E0 90                      NOP
06E1 90                      NOP
06E2 90                      NOP
06E3 90                      NOP
06E4 90                      NOP
06E5 90                      NOP
06E6 90                      NOP
06E7 90                      NOP
06E8 90                      NOP
06E9 90                      NOP
06EA 90                      NOP
06EB 90                      NOP
06EC 90                      NOP
06ED 90                      NOP
06EE 90                      NOP
06EF 90                      NOP
06F0 90                      NOP
06F1 90                      NOP
06F2 90                      NOP
06F3 90                      NOP
06F4 90                      NOP
06F5 90                      NOP
06F6 90                      NOP
06F7 90                      NOP
06F8 90                      NOP
06F9 90                      NOP
06FA 90                      NOP
06FB 90                      NOP
06FC 90                      NOP
06FD 90                      NOP
06FE 90                      NOP
06FF 90                      NOP
0700 90                      NOP
0701 90                      NOP
0702 90                      NOP
0703 90                      NOP
0704 90                      NOP
0705 90                      NOP
0706 90                      NOP
0707 90                      NOP
0708 90                      NOP
0709 90                      NOP
070A 90                      NOP
070B 90                      NOP
070C 90                      NOP
070D 90                      NOP
070E 90                      NOP
070F 90                      NOP
0710 90                      NOP
0711 90                      NOP
0712 90                      NOP
0713 90                      NOP
0714 90                      NOP
0715 90                      NOP
0716 90                      NOP
0717 90                      NOP
0718 90                      NOP
0719 90                      NOP
071A 90                      NOP
071B 90                      NOP
071C 90                      NOP
071D 90                      NOP
071E 90                      NOP
071F 90                      NOP
0720 90                      NOP
0721 90                      NOP
0722 90                      NOP
0723 90                      NOP
0724 90                      NOP
0725 90                      NOP
0726 90                      NOP
0727 90                      NOP
0728 90                      NOP
0729 90                      NOP
072A 90                      NOP
072B 90                      NOP
072C 90                      NOP
072D 90                      NOP
072E 90                      NOP
072F 90                      NOP
0730 90                      NOP
0731 90                      NOP
0732 90                      NOP
0733 90                      NOP
0734 90                      NOP
0735 90                      NOP
0736 90                      NOP
0737 90                      NOP
0738 90                      NOP
0739 90                      NOP
073A 90                      NOP
073B 90                      NOP
073C 90                      NOP
073D 90                      NOP
073E 90                      NOP
073F 90                      NOP
0740 90                      NOP
0741 90                      NOP
0742 90                      NOP
0743 90                      NOP
0744 90                      NOP
0745 90                      NOP
0746 90                      NOP
0747 90                      NOP
0748 90                      NOP
0749 90                      NOP
074A 90                      NOP
074B 90                      NOP
074C 90                      NOP
074D 90                      NOP
074E 90                      NOP
074F 90                      NOP
0750 90                      NOP
0751 90                      NOP
0752 90                      NOP
0753 90                      NOP
0754 90                      NOP
0755 90                      NOP
0756 90                      NOP
0757 90                      NOP
0758 90                      NOP
0759 90                      NOP
075A 90                      NOP
075B 90                      NOP
075C 90                      NOP
075D 90                      NOP
075E 90                      NOP
075F 90                      NOP
0760 90                      NOP
0761 90                      NOP
0762 90                      NOP
0763 90                      NOP
0764 90                      NOP
0765 90                      NOP
0766 90                      NOP
0767 90                      NOP
0768 90                      NOP
0769 90                      NOP
076A 90                      NOP
076B 90                      NOP
076C 90                      NOP
076D 90                      NOP
076E 90                      NOP
076F 90                      NOP
0770 90                      NOP
0771 90                      NOP
0772 90                      NOP
0773 90                      NOP
0774 90                      NOP
0775 90                      NOP
0776 90                      NOP
0777 90                      NOP
0778 90                      NOP
0779 90                      NOP
077A 90                      NOP
077B 90                      NOP
077C 90                      NOP
077D 90                      NOP
077E 90                      NOP
077F 90                      NOP
0780 90                      NOP
0781 90                      NOP
0782 90                      NOP
0783 90                      NOP
0784 90                      NOP
0785 90                      NOP
0786 90                      NOP
0787 90                      NOP
0788 90                      NOP
0789 90                      NOP
078A 90                      NOP
078B 90                      NOP
078C 90                      NOP
078D 90                      NOP
078E 90                      NOP
078F 90                      NOP
0790 90                      NOP
0791 90                      NOP
0792 90                      NOP
0793 90                      NOP
0794 90                      NOP
0795 90                      NOP
0796 90                      NOP
0797 90                      NOP
0798 90                      NOP
0799 90                      NOP
079A 90                      NOP
079B 90                      NOP
079C 90                      NOP
079D 90                      NOP
079E 90                      NOP
079F 90                      NOP
07A0 90                      NOP
07A1 90                      NOP
07A2 90                      NOP
07A3 90                      NOP
07A4 90                      NOP
07A5 90                      NOP
07A6 90                      NOP
07A7 90                      NOP
07A8 90                      NOP
07A9 90                      NOP
07AA 90                      NOP
07AB 90                      NOP
07AC 90                      NOP
07AD 90                      NOP
07AE 90                      NOP
07AF 90                      NOP
07B0 90                      NOP
07B1 90                      NOP
07B2 90                      NOP
07B3 90                      NOP
07B4 90                      NOP
07B5 90                      NOP
07B6 90                      NOP
07B7 90                      NOP
07B8 90                      NOP
07B9 90                      NOP
07BA 90                      NOP
07BB 90                      NOP
07BC 90                      NOP
07BD 90                      NOP
07BE 90                      NOP
07BF 90                      NOP
07C0 90                      NOP
07C1 90                      NOP
07C2 90                      NOP
07C3 90                      NOP
07C4 90                      NOP
07C5 90                      NOP
07C6 90                      NOP
07C7 90                      NOP
07C8 90                      NOP
07C9 90                      NOP
07CA 90                      NOP
07CB 90                      NOP
07CC 90                      NOP
07CD 90                      NOP
07CE 90                      NOP
07CF 90                      NOP
07D0 90                      NOP
07D1 90                      NOP
07D2 90                      NOP
07D3 90                      NOP
07D4 90                      NOP
07D5 90                      NOP
07D6 90                      NOP
07D7 90                      NOP
07D8 90                      NOP
07D9 90                      NOP
07DA 90                      NOP
07DB 90                      NOP
07DC 90                      NOP
07DD 90                      NOP
07DE 90                      NOP
07DF 90                      NOP
07E0 90                      NOP
07E1 90                      NOP
07E2 90                      NOP
07E3 90                      NOP
07E4 90                      NOP
07E5 90                      NOP
07E6 90                      NOP
07E7 90                      NOP
07E8 90                      NOP
07E9 90                      NOP
07EA 90                      NOP
07EB 90                      NOP
07EC 90                      NOP
07ED 90                      NOP
07EE 90                      NOP
07EF 90                      NOP
07F0 90                      NOP
07F1 90                      NOP
07F2 90                      NOP
07F3 90                      NOP
07F4 90                      NOP
07F5 90                      NOP
07F6 90                      NOP
07F7 90                      NOP
07F8 90                      NOP
07F9 90                      NOP
07FA 90                      NOP
07FB 90                      NOP
07FC 90                      NOP
07FD 90                      NOP
07FE 90                      NOP
07FF 90                      NOP
0800 90                      NOP
0801 90                      NOP
0802 90                      NOP
0803 90                      NOP
0804 90                      NOP
0805 90                      NOP
0806 90                      NOP
0807 90                      NOP
0808 90                      NOP
0809 90                      NOP
080A 90                      NOP
080B 90                      NOP
080C 90                      NOP
080D 90                      NOP
080E 90                      NOP
080F 90                      NOP
0810 90                      NOP
0811 90                      NOP
0812 90                      NOP
0813 90                      NOP
0814 90                      NOP
0815 90                      NOP
0816 90                      NOP
0817 90                      NOP
0818 90                      NOP
0819 90                      NOP
081A 90                      NOP
081B 90                      NOP
081C 90                      NOP
081D 90                      NOP
081E 90                      NOP
081F 90                      NOP
0820 90                      NOP
0821 90                      NOP
0822 90                      NOP
0823 90                      NOP
0824 90                      NOP
0825 90                      NOP
0826 90                      NOP
0827 90                      NOP
0828 90                      NOP
0829 90                      NOP
082A 90                      NOP
082B 90                      NOP
082C 90                      NOP
082D 90                      NOP
082E 90                      NOP
082F 90                      NOP
0830 90                      NOP
0831 90                      NOP
0832 90                      NOP
0833 90                      NOP
0834 90                      NOP
0835 90                      NOP
0836 90                      NOP
0837 90                      NOP
0838 90                      NOP
0839 90                      NOP
083A 90                      NOP
083B 90                      NOP
083C 90                      NOP
083D 90                      NOP
083E 90                      NOP
083F 90                      NOP
0840 90                      NOP
0841 90                      NOP
0842 90                      NOP
0843 90                      NOP
0844 90                      NOP
0845 90                      NOP
0846 90                      NOP
0847 90                      NOP
0848 90                      NOP
0849 90                      NOP
084A 90                      NOP
084B 90                      NOP
084C 90                      NOP
084D 90                      NOP
084E 90                      NOP
084F 90                      NOP
0850 90                      NOP
0851 90                      NOP
0852 90                      NOP
0853 90                      NOP
0854 90                      NOP
0855 90                      NOP
0856 90                      NOP
0857 90                      NOP
0858 90                      NOP
0859 90                      NOP
085A 90                      NOP
085B 90                      NOP
085C 90                      NOP
085D 90                      NOP
085E 90                      NOP
085F 90                      NOP
0860 90                      NOP
0861 90                      NOP
0862 90                      NOP
0863 90                      NOP
0864 90                      NOP
0865 90                      NOP
0866 90                      NOP
0867 90                      NOP
0868 90                      NOP
0869 90                      NOP
086A 90                      NOP
086B 90                      NOP
086C 90                      NOP
086D 90                      NOP
086E 90                      NOP
086F 90                      NOP
0870 90                      NOP
0871 90                      NOP
0872 90                      NOP
0873 90                      NOP
0874 90                      NOP
0875 90                      NOP
0876 90                      NOP
0877 90                      NOP
0878 90                      NOP
0879 90                      NOP
087A 90                      NOP
087B 90                      NOP
087C 90                      NOP
087D 90                      NOP
087E 90                      NOP
087F 90                      NOP
0880 90                      NOP
0881 90                      NOP
0882 90                      NOP
0883 90                      NOP
0884 90                      NOP
0885 90                      NOP
0886 90                      NOP
0887 90                      NOP
0888 90                      NOP
0889 90                      NOP
088A 90                      NOP
088B 90                      NOP
088C 90                      NOP
088D 90                      NOP
088E 90                      NOP
088F 90                      NOP
0890 90                      NOP
0891 90                      NOP
0892 90                      NOP
0893 90                      NOP
0894 90                      NOP
0895 90                      NOP
0896 90                      NOP
0897 90                      NOP
0898 90                      NOP
0899 90                      NOP
089A 90                      NOP
089B 90                      NOP
089C 90                      NOP
089D 90                      NOP
089E 90                      NOP
089F 90                      NOP
08A0 90                      NOP
08A1 90                      NOP
08A2 90                      NOP
08A3 90                      NOP
08A4 90                      NOP
08A5 90                      NOP
08A6 90                      NOP
08A7 90                      NOP
08A8 90                      NOP
08A9 90                      NOP
08AA 90                      NOP
08AB 90                      NOP
08AC 90                      NOP
08AD 90                      NOP
08AE 90                      NOP
08AF 90                      NOP
08B0 90                      NOP
08B1 90                      NOP
08B2 90                      NOP
08B3 90                      NOP
08B4 90                      NOP
08B5 90                      NOP
08B6 90                      NOP
08B7 90                      NOP
08B8 90                      NOP
08B9 90                      NOP
08BA 90                      NOP
08BB 90                      NOP
08BC 90                      NOP
08BD 90                      NOP
08BE 90                      NOP
08BF 90                      NOP
08C0 90                      NOP
08C1 90                      NOP
08C2 90                      NOP
08C3 90                      NOP
08C4 90                      NOP
08C5 90                      NOP
08C6 90                      NOP
08C7 90                      NOP
08C8 90                      NOP
08C9 90                      NOP
08CA 90                      NOP
08CB 90                      NOP
08CC 90                      NOP
08CD 90                      NOP
08CE 90                      NOP
08CF 90                      NOP
08D0 90                      NOP
08D1 90                      NOP
08D2 90                      NOP
08D3 90                      NOP
08D4 90                      NOP
08D5 90                      NOP
08D6 90                      NOP
08D7 90                      NOP
08D8 90                      NOP
08D9 90                      NOP
08DA 90                      NOP
08DB 90                      NOP
08DC 90                      NOP
08DD 90                      NOP
08DE 90                      NOP
08DF 90                      NOP
08E0 90                      NOP
08E1 90                      NOP
08E2 90                      NOP
08E3 90                      NOP
08E4 90                      NOP
08E5 90                      NOP
08E6 90                      NOP
08E7 90                      NOP
08E8 90                      NOP
08E9 90                      NOP
08EA 90                      NOP
08EB 90                      NOP
08EC 90                      NOP
08ED 90                      NOP
08EE 90                      NOP
08EF E8 00 00                CALL 08F2
08F2 5D                      POP BP
08F3 81 ED 03 00             SUB BP,3
08F7 E8 3F 04                CALL 0D39
08FA 0F F5                   DB 0F,0F5
08FC F6 7A 96                IDIV B[BP+SI-06A]
08FF 8A 86 94 C3             MOV AL,B[BP+0C394]
0903 82                      DB 082
0904 A9 B1 B9                TEST AX,0B9B1
0907 A8 B9                   TEST AL,0B9
0909 B0 3B                   MOV AL,03B
090B 77 FF                   JA 090C
090D 39 6F 36                CMP W[BX+036],BP
0910 99                      CWD
0911 B4 B7                   MOV AH,0B7
0913 38 B7 36 99             CMP B[BX+09936],DH
0917 A5                      MOVSW
0918 B7 38                   MOV BH,038
091A B7 16                   MOV BH,016
091C A5                      MOVSW
091D B7 39                   MOV BH,039
091F 6F                      OUTSW
0920 F7 39                   IDIV W[BX+DI]
0922 77 71                   JA 0995
0924 B1 B7                   MOV CL,0B7
0926 B7 ED                   MOV BH,0ED
0928 70 B1                   JO 08DB
092A B6 B7                   MOV DH,0B7
092C BF B7 70                MOV DI,070B7
092F B1 B4                   MOV CL,0B4
0931 B7 39                   MOV BH,039
0933 B7 B9                   MOV BH,0B9
0935 A8 5C                   TEST AL,05C
0937 B3 27                   MOV BL,027
0939 5C                      POP SP
093A EC                      IN AL,DX
093B 27                      DAA
093C 84 48 0E                TEST B[BX+SI+0E],CL
093F 87 B5 3C 42             XCHG W[DI+0423C],SI
0943 44                      INC SP
0944 12 84 77 39             ADC AL,B[SI+03977]
0948 6F                      OUTSW
0949 A9 72 B1                TEST AX,0B172
094C 33 B7 91 14             XOR SI,W[BX+01491]
0950 46                      INC SI
0951 B6 91                   MOV DH,091
0953 3B A9 44 B6             CMP BP,W[BX+DI+0B644]
0957 A8 A9                   TEST AL,0A9
0959 72 B1                   JB 090C
095B 97                      XCHG AX,DI
095C B7 91                   MOV BH,091
095E 14 69                   ADC AL,069
0960 B6 91                   MOV DH,091
0962 3B A9 57 B6             CMP BP,W[BX+DI+0B657]
0966 A8 A9                   TEST AL,0A9
0968 72 B1                   JB 091B
096A 93                      XCHG AX,BX
096B B7 91                   MOV BH,091
096D 14 BF                   ADC AL,0BF
096F B6 91                   MOV DH,091
0971 3B A9 BD B6             CMP BP,W[BX+DI+0B6BD]
0975 A8 70                   TEST AL,070
0977 B1 33                   MOV CL,033
0979 B7 55                   MOV BH,055
097B B6 3B                   MOV DH,03B
097D B1 31                   MOV CL,031
097F B7 70                   MOV BH,070
0981 B1 97                   MOV CL,097
0983 B7 E4                   MOV BH,0E4
0985 B6 3B                   MOV DH,03B
0987 B1 95                   MOV CL,095
0989 B7 70                   MOV BH,070
098B B1 93                   MOV CL,093
098D B7 48                   MOV BH,048
098F B7 3B                   MOV BH,03B
0991 B1 91                   MOV CL,091
0993 B7 B0                   MOV BH,0B0
0995 A8 36                   TEST AL,036
0997 4B                      DEC BX
0998 F5                      CMC
0999 F6 C3 B9                TEST BL,0B9
099C 3A 01                   CMP AL,B[BX+DI]
099E 82                      DB 082
099F B4 08                   MOV AH,8
09A1 B7 B6                   MOV BH,0B6
09A3 E0 13                   LOOPNE 09B8
09A5 12 12                   ADC DL,B[BP+SI]
09A7 5C                      POP SP
09A8 A4                      MOVSB
09A9 27                      DAA
09AA A9 B1 B9                TEST AX,0B9B1
09AD A8 B9                   TEST AL,0B9
09AF B0 3A                   MOV AL,03A
09B1 01 40 B7                ADD W[BX+SI-049],AX
09B4 3A 09                   CMP CL,B[BX+DI]
09B6 58                      POP AX
09B7 B7 12                   MOV BH,012
09B9 12 12                   ADC DL,B[BP+SI]
09BB 12 36 4B 89             ADC DH,B[0894B]
09BF F6 C3 B6                TEST BL,0B6
09C2 74 B0                   JE 0974
09C4 A8 3B                   TEST AL,03B
09C6 77 B2                   JA 097A
09C8 A7                      CMPSW
09C9 B7 99                   MOV BH,099
09CB B6 31                   MOV DH,031
09CD 46                      INC SI
09CE B7 99                   MOV BH,099
09D0 B4 31                   MOV AH,031
09D2 42                      INC DX
09D3 B7 4D                   MOV BH,04D
09D5 99                      CWD
09D6 3C 11                   CMP AL,011
09D8 44                      INC SP
09D9 B7 39                   MOV BH,039
09DB 67                      DB 067
09DC 4C                      DEC SP
09DD 5D                      POP BP
09DE B7 B7                   MOV BH,0B7
09E0 B7 B7                   MOV BH,0B7
09E2 B7 B7                   MOV BH,0B7
09E4 B7 B7                   MOV BH,0B7
09E6 B7 B7                   MOV BH,0B7
09E8 47                      INC DI
09E9 48                      DEC AX
09EA B7 B7                   MOV BH,0B7
09EC B7 B7                   MOV BH,0B7
09EE E7 53                   OUT 053,AX
09F0 D7                      XLATB
09F1 8B E4                   MOV SP,SP
09F3 C3                      RET
09F4 B1 EF                   MOV CL,0EF
09F6 5D                      POP BP
09F7 30 5E B7                XOR B[BP-049],BL
09FA 47                      INC DI
09FB E7 E4                   OUT 0E4,AX
09FD E6 E5                   OUT 0E5,AL
09FF A9 B1 84                TEST AX,084B1
0A02 77 7A                   JA 0A7E
0A04 AD                      LODSW
0A05 34 4E                   XOR AL,04E
0A07 BE C5 9B                MOV SI,09BC5
0A0A 34 4E                   XOR AL,04E
0A0C B8 C0 90                MOV AX,090C0
0A0F B9 A8 B9                MOV CX,0B9A8
0A12 B0 84                   MOV AL,084
0A14 77 07                   JA 0A1D
0A16 B4 7A                   MOV AH,07A
0A18 A7                      CMPSW
0A19 03 BE 0D E6             ADD DI,W[BP+0E60D]
0A1D B4 7A                   MOV AH,07A
0A1F 96                      XCHG AX,SI
0A20 0E                      PUSH CS
0A21 B2 B7                   MOV DL,0B7
0A23 E6 03                   OUT 3,AL
0A25 B7 7A                   MOV BH,07A
0A27 AD                      LODSW
0A28 34 75                   XOR AL,075
0A2A A5                      MOVSW
0A2B 3C 6D                   CMP AL,06D
0A2D 7A AD                   JPE 09DC
0A2F 8C 64 C2                MOV W[SI-03E],ES
0A32 4D                      DEC BP
0A33 EE                      OUT DX,AL
0A34 55                      PUSH BP
0A35 5A                      POP DX
0A36 B0 A8                   MOV AL,0A8
0A38 ED                      IN AX,DX
0A39 EE                      OUT DX,AL
0A3A EC                      IN AL,DX
0A3B EF                      OUT DX,AX
0A3C 5D                      POP BP
0A3D 47                      INC DI
0A3E 48                      DEC AX
0A3F 48                      DEC AX
0A40 48                      DEC AX
0A41 78 E7                   JS 0A2A
0A43 E4 E6                   IN AL,0E6
0A45 E5 B1                   IN AX,0B1
0A47 A9 B9 A8                TEST AX,0A8B9
0A4A B9 B0 84                MOV CX,084B0
0A4D 77 7A                   JA 0AC9
0A4F AD                      LODSW
0A50 34 4E                   XOR AL,04E
0A52 BE C5 C6                MOV SI,0C6C5
0A55 34 4E                   XOR AL,04E
0A57 B8 C0 DB                MOV AX,0DBC0
0A5A 03 B4 84 6C             ADD SI,W[SI+06C84]
0A5E 7A A7                   JPE 0A07
0A60 E5 3D                   IN AX,03D
0A62 81 8C B4 3D A1 8D       OR W[SI+03DB4],08DA1
0A68 B4 03                   MOV AH,3
0A6A B5 84                   MOV CH,084
0A6C 6C                      INSB
0A6D 7A A7                   JPE 0A16
0A6F 03 BD 07 97             ADD DI,W[DI+09707]
0A73 84 6C 0E                TEST B[SI+0E],CH
0A76 B6 B7                   MOV DH,0B7
0A78 7A A7                   JPE 0A21
0A7A 37                      AAA
0A7B 49                      DEC CX
0A7C AF                      SCASW
0A7D CB                      RETF
0A7E B2 71                   MOV DL,071
0A80 B1 03                   MOV CL,3
0A82 B6 79                   MOV DH,079
0A84 37                      AAA
0A85 49                      DEC CX
0A86 B7 C0                   MOV BH,0C0
0A88 B2 71                   MOV DL,071
0A8A B1 03                   MOV CL,3
0A8C B6 71                   MOV DH,071
0A8E 37                      AAA
0A8F 4D                      DEC BP
0A90 F8                      CLC
0A91 CB                      RETF
0A92 B2 71                   MOV DL,071
0A94 B1 01                   MOV CL,1
0A96 B6 7D                   MOV DH,07D
0A98 37                      AAA
0A99 4D                      DEC BP
0A9A B7 C0                   MOV BH,0C0
0A9C B2 71                   MOV DL,071
0A9E B1 01                   MOV CL,1
0AA0 B6 75                   MOV DH,075
0AA2 49                      DEC CX
0AA3 71 49                   JNO 0AEE
0AA5 7D 3F                   JGE 0AE6
0AA7 A1 8D B4                MOV AX,W[0B48D]
0AAA 3F                      AAS
0AAB 81 8C B4 03 B5 84       OR W[SI+03B4],084B5
0AB1 6C                      INSB
0AB2 7A A7                   JPE 0A5B
0AB4 03 BD 07 9D             ADD DI,W[DI+09D07]
0AB8 84 6C 0E                TEST B[SI+0E],CH
0ABB B6 B7                   MOV DH,0B7
0ABD 7A A7                   JPE 0A66
0ABF 03 B5 84 6C             ADD SI,W[DI+06C84]
0AC3 ED                      IN AX,DX
0AC4 7A A7                   JPE 0A6D
0AC6 A8 B0                   TEST AL,0B0
0AC8 ED                      IN AX,DX
0AC9 EE                      OUT DX,AL
0ACA EC                      IN AL,DX
0ACB EF                      OUT DX,AX
0ACC 5D                      POP BP
0ACD 12 49 B7                ADC CL,B[BX+DI-049]
0AD0 47                      INC DI
0AD1 8A B7 FC C3             MOV DH,B[BX+0C3FC]
0AD5 B9 8A F5                MOV CX,0F58A
0AD8 F6 C2 B3                TEST DL,0B3
0ADB 0F 86                   DB 0F,086
0ADD 94                      XCHG AX,SP
0ADE 78 5D                   JS 0B3D
0AE0 29 A7 A1 B6             SUB W[BX+0B6A1],SP
0AE4 2B E7                   SUB SP,DI
0AE6 E4 E6                   IN AL,0E6
0AE8 E5 E1                   IN AX,0E1
0AEA E0 A9                   LOOPNE 0A95
0AEC B1 0F                   MOV CL,0F
0AEE B7 F4                   MOV BH,0F4
0AF0 7A 96                   JPE 0A88
0AF2 A9 E5 E6                TEST AX,0E6E5
0AF5 84 7E 0F                TEST B[BP+0F],BH
0AF8 B6 F4                   MOV DH,0F4
0AFA 7A 96                   JPE 0A92
0AFC 0F B5                   DB 0F,0B5
0AFE 8A 7A 96                MOV BH,B[BP+SI-06A]
0B01 24 0F                   AND AL,0F
0B03 B7 E0                   MOV BH,0E0
0B05 7A 96                   JPE 0A9D
0B07 E6 E5                   OUT 0E5,AL
0B09 B9 A8 B9                MOV CX,0B9A8
0B0C B0 03                   MOV AL,3
0B0E 88 0E AD B7             MOV B[0B7AD],CL
0B12 0D 0B BF                OR AX,0BF0B
0B15 7A 96                   JPE 0AAD
0B17 0F B5                   DB 0F,0B5
0B19 F5                      CMC
0B1A 84 7E 84                TEST B[BP-07C],BH
0B1D 65 7A 96                REPC JPE 0AB6
0B20 36 89 0B                SS MOV W[BP+DI],CX
0B23 BF FA ED                MOV DI,0EDFA
0B26 C3                      RET
0B27 BC 36 89                MOV SP,08936
0B2A 08 BF F5 F6             OR B[BX+0F6F5],BH
0B2E C3                      RET
0B2F EC                      IN AL,DX
0B30 5C                      POP SP
0B31 A0 27 36                MOV AL,B[03627]
0B34 89 7B BF                MOV W[BP+DI-041],DI
0B37 F5                      CMC
0B38 F6 C3 E7                TEST BL,0E7
0B3B 5C                      POP SP
0B3C 9D                      POPF
0B3D 27                      DAA
0B3E B0 A8                   MOV AL,0A8
0B40 E8 E9 ED                CALL 0F92C
0B43 EE                      OUT DX,AL
0B44 EC                      IN AL,DX
0B45 EF                      OUT DX,AX
0B46 2A 5C 21                SUB BL,B[SI+021]
0B49 9A B4 B7 09 0B          CALL 0B09:0B7B4
0B4E BF 08 82                MOV DI,08208
0B51 B4 13                   MOV AH,013
0B53 12 12                   ADC DL,B[BP+SI]
0B55 71 F3                   JNO 0B4A
0B57 4C                      DEC SP
0B58 5E                      POP SI
0B59 3E F3 4B                DS REP DEC BX
0B5C 70 F3                   JO 0B51
0B5E 49                      DEC CX
0B5F F5                      CMC
0B60 F6 0E                   DB 0F6,0E
0B62 B2 B7                   MOV DL,0B7
0B64 5C                      POP SP
0B65 DE 27                   FISUB W[BX]
0B67 E4 E5                   IN AL,0E5
0B69 E7 73                   OUT 073,AX
0B6B B1 67                   MOV CL,067
0B6D BF 14 40                MOV DI,04014
0B70 B7 3B                   MOV BH,03B
0B72 B1 4E                   MOV CL,04E
0B74 B7 73                   MOV BH,073
0B76 B1 7D                   MOV CL,07D
0B78 BF 3B B1                MOV DI,0B13B
0B7B 4C                      DEC SP
0B7C B7 14                   MOV BH,014
0B7E 4A                      DEC DX
0B7F B7 16                   MOV BH,016
0B81 73 BF                   JAE 0B42
0B83 06                      PUSH ES
0B84 B3 64                   MOV BL,064
0B86 57                      PUSH DI
0B87 24 5C                   AND AL,05C
0B89 B3 27                   MOV BL,027
0B8B 5E                      POP SI
0B8C 37                      AAA
0B8D B7 EF                   MOV BH,0EF
0B8F ED                      IN AX,DX
0B90 E7 E5                   OUT 0E5,AX
0B92 9C                      PUSHF
0B93 74 34                   JE 0BC9
0B95 6D                      INSW
0B96 B7 0E                   MOV BH,0E
0B98 A7                      CMPSW
0B99 B7 40                   MOV BH,040
0B9B 46                      INC SI
0B9C 3E A1 67 BF             DS MOV AX,W[0BF67]
0BA0 14 65                   ADC AL,065
0BA2 BF 14 7D                MOV DI,07D14
0BA5 BF 70 B1                MOV DI,0B170
0BA8 7B BF                   JPO 0B69
0BAA F5                      CMC
0BAB F6 ED                   IMUL CH
0BAD EF                      OUT DX,AX
0BAE B2 E9                   MOV DL,0E9
0BB0 B3 34                   MOV BL,034
0BB2 65 B7 06                REPC MOV BH,6
0BB5 BE E7 64                MOV SI,064E7
0BB8 5F                      POP DI
0BB9 64 7D 4E                REPNC JGE 0C0A
0BBC A4                      MOVSB
0BBD 67                      DB 067
0BBE EF                      OUT DX,AX
0BBF 37                      AAA
0BC0 53                      PUSH BX
0BC1 B6 3E                   MOV DH,03E
0BC3 A1 77 BF                MOV AX,W[0BF77]
0BC6 14 09                   ADC AL,9
0BC8 BF B9 B0                MOV DI,0B0B9
0BCB 0E                      PUSH CS
0BCC AD                      LODSW
0BCD B7 EC                   MOV BH,0EC
0BCF E6 85                   OUT 085,AL
0BD1 53                      PUSH BX
0BD2 7A AD                   JPE 0B81
0BD4 53                      PUSH BX
0BD5 F7 85 76 85 75 8B       TEST W[DI+08576],08B75
0BDB B7 C3                   MOV BH,0C3
0BDD 45                      INC BP
0BDE 15 EA B3                ADC AX,0B3EA
0BE1 84 41 08                TEST B[BX+DI+8],AL
0BE4 E9 B3 0E                JMP 01A9A
0BE7 E9 B3 44                JMP 0509D
0BEA 13 E2                   ADC SP,DX
0BEC 0A E9                   OR CH,CL
0BEE B3 5F                   MOV BL,05F
0BF0 F0 B6 EA                LOCK MOV DH,0EA
0BF3 03 F7                   ADD SI,DI
0BF5 0D E9 B3                OR AX,0B3E9
0BF8 0E                      PUSH CS
0BF9 E9 B3 7A                JMP 086AF
0BFC 96                      XCHG AX,SI
0BFD 0F B7                   DB 0F,0B7
0BFF F5                      CMC
0C00 84 7E 84                TEST B[BP-07C],BH
0C03 65 7A 96                REPC JPE 0B9C
0C06 03 F7                   ADD SI,DI
0C08 0D 0B BF                OR AX,0BF0B
0C0B EE                      OUT DX,AL
0C0C 7A 96                   JPE 0BA4
0C0E 0F B6                   DB 0F,0B6
0C10 E0 ED                   LOOPNE 0BFF
0C12 EE                      OUT DX,AL
0C13 7A 96                   JPE 0BAB
0C15 03 89 7A 96             ADD CX,W[BX+DI+0967A]
0C19 EE                      OUT DX,AL
0C1A ED                      IN AX,DX
0C1B A8 0F                   TEST AL,0F
0C1D B6 F4                   MOV DH,0F4
0C1F 7A 96                   JPE 0BB7
0C21 5E                      POP SI
0C22 AD                      LODSW
0C23 48                      DEC AX
0C24 B9 A8 03                MOV CX,03A8
0C27 BE 0D FC                MOV SI,0FC0D
0C2A A6                      CMPSB
0C2B F6 D3                   NOT BL
0C2D DA DE                   DB 0DA,0DE
0C2F C5 D6                   LDS DX,SI
0C31 DB 97 F5 D6             FIST D[BX+0D6F5]
0C35 DE DB                   DB 0DE,0DB
0C37 D2 CE                   ROR DH,CL
0C39 97                      XCHG AX,DI
0C3A EC                      IN AL,DX
0C3B EE                      OUT DX,AL
0C3C F6 FA                   IDIV DL
0C3E EA B7 BA BD 97          JMP 097BD:0BAB7
0C43 9D                      POPF
0C44 9D                      POPF
0C45 9D                      POPF
0C46 EC                      IN AL,DX
0C47 97                      XCHG AX,DI
0C48 FD                      STD
0C49 C2 C4 C3                RET 0C3C4
0C4C 97                      XCHG AX,DI
0C4D C0 D6 D9                RCL DH,-027
0C50 D9 D6                   DB 0D9,0D6
0C52 97                      XCHG AX,DI
0C53 C4 D6                   LES DX,SI
0C55 CE                      INTO
0C56 97                      XCHG AX,DI
0C57 E0 D6                   LOOPNE 0C2F
0C59 90                      NOP
0C5A E4 C2                   IN AL,0C2
0C5C C7 97 C3 D8 8D 97       MOV W[BX+0D8C3],0978D
0C62 EA 9D 9D 9D 9D          JMP 09D9D:09D9D
0C67 9D                      POPF
0C68 9D                      POPF
0C69 9D                      POPF
0C6A 9D                      POPF
0C6B 9D                      POPF
0C6C 9D                      POPF
0C6D 9D                      POPF
0C6E 9D                      POPF
0C6F 9D                      POPF
0C70 9D                      POPF
0C71 9D                      POPF
0C72 9D                      POPF
0C73 9D                      POPF
0C74 9D                      POPF
0C75 9D                      POPF
0C76 9D                      POPF
0C77 9D                      POPF
0C78 9D                      POPF
0C79 9D                      POPF
0C7A 9D                      POPF
0C7B 9D                      POPF
0C7C 9D                      POPF
0C7D 9D                      POPF
0C7E 9D                      POPF
0C7F 9D                      POPF
0C80 9D                      POPF
0C81 9D                      POPF
0C82 9D                      POPF
0C83 9D                      POPF
0C84 9D                      POPF
0C85 9D                      POPF
0C86 9D                      POPF
0C87 9D                      POPF
0C88 9D                      POPF
0C89 9D                      POPF
0C8A 9D                      POPF
0C8B 9D                      POPF
0C8C 9D                      POPF
0C8D 9D                      POPF
0C8E 9D                      POPF
0C8F 9D                      POPF
0C90 9D                      POPF
0C91 BD BA 97                MOV BP,097BA
0C94 97                      XCHG AX,DI
0C95 97                      XCHG AX,DI
0C96 97                      XCHG AX,DI
0C97 97                      XCHG AX,DI
0C98 97                      XCHG AX,DI
0C99 97                      XCHG AX,DI
0C9A 97                      XCHG AX,DI
0C9B 97                      XCHG AX,DI
0C9C 97                      XCHG AX,DI
0C9D 97                      XCHG AX,DI
0C9E 97                      XCHG AX,DI
0C9F 97                      XCHG AX,DI
0CA0 97                      XCHG AX,DI
0CA1 E3 DF                   JCXZ 0C82
0CA3 D2 97 F4 D6             RCL B[BX+0D6F4],CL
0CA7 C5 DA                   LDS BX,DX
0CA9 D2 DB                   RCR BL,CL
0CAB 97                      XCHG AX,DI
0CAC FA                      CLI
0CAD D6                      DB 0D6
0CAE C4 C4                   LES AX,SP
0CB0 DE C1                   FADD
0CB2 D2 BD BA 97             SAR B[DI+097BA],CL
0CB6 97                      XCHG AX,DI
0CB7 97                      XCHG AX,DI
0CB8 97                      XCHG AX,DI
0CB9 97                      XCHG AX,DI
0CBA 97                      XCHG AX,DI
0CBB 97                      XCHG AX,DI
0CBC 97                      XCHG AX,DI
0CBD 97                      XCHG AX,DI
0CBE 97                      XCHG AX,DI
0CBF 97                      XCHG AX,DI
0CC0 97                      XCHG AX,DI
0CC1 97                      XCHG AX,DI
0CC2 97                      XCHG AX,DI
0CC3 E3 DF                   JCXZ 0CA4
0CC5 D2 97 FD D6             RCL B[BX+0D6FD],CL
0CC9 DA D6                   DB 0DA,0D6
0CCB DE D4                   DB 0DE,0D4
0CCD D6                      DB 0D6
0CCE D9 97 E7 D8             FST D[BX+0D8E7]
0CD2 C4 C4                   LES AX,SP
0CD4 D2 97 D6 D9             RCL B[BX+0D9D6],CL
0CD8 D3 BD BA 97             SAR W[DI+097BA],CL
0CDC 97                      XCHG AX,DI
0CDD 97                      XCHG AX,DI
0CDE 97                      XCHG AX,DI
0CDF 97                      XCHG AX,DI
0CE0 97                      XCHG AX,DI
0CE1 97                      XCHG AX,DI
0CE2 97                      XCHG AX,DI
0CE3 97                      XCHG AX,DI
0CE4 97                      XCHG AX,DI
0CE5 97                      XCHG AX,DI
0CE6 97                      XCHG AX,DI
0CE7 97                      XCHG AX,DI
0CE8 97                      XCHG AX,DI
0CE9 FA                      CLI
0CEA D6                      DB 0D6
0CEB D3 97 F4 D8             RCL W[BX+0D8F4],CL
0CEF D5 C5                   AAD 0C5
0CF1 D6                      DB 0D6
0CF2 99                      CWD
0CF3 97                      XCHG AX,DI
0CF4 FC                      CLD
0CF5 D2 D2                   RCL DL,CL
0CF7 C7 97 C3 DF D2 97       MOV W[BX+0DFC3],097D2
0CFD F1                      DB 0F1
0CFE FB                      STI
0CFF F2 EF                   REPNE OUT DX,AX
0D01 97                      XCHG AX,DI
0D02 D6                      DB 0D6
0D03 DB DE                   DB 0DB,0DE
0D05 C1 D2 96                RCL DX,-06A
0D08 BD BA BA                MOV BP,0BABA
0D0B BD F5 CE                MOV BP,0CEF5
0D0E 9A E3 DF D2 9A          CALL 09AD2:0DFE3
0D13 E0 D6                   LOOPNE 0CEB
0D15 CE                      INTO
0D16 97                      XCHG AX,DI
0D17 FD                      STD
0D18 D8 DF                   FCOMP 7
0D1A D9 97 D4 D6             FST D[BX+0D6D4]
0D1E DB DB                   DB 0DB,0DB
0D20 97                      XCHG AX,DI
0D21 C3                      RET
0D22 DF DE                   DB 0DF,0DE
0D24 C4 97 D8 D9             LES DX,[BX+0D9D8]
0D28 D2 97 95 F0             RCL B[BX+0F095],CL
0D2C C5 D2                   LDS DX,DX
0D2E D2 C3                   ROL BL,CL
0D30 DE D9                   FCOMPP
0D32 D0 C4                   ROL AH,1
0D34 95                      XCHG AX,BP
0D35 99                      CWD
0D36 BD BA 93                MOV BP,093BA
0D39 2E 8A A6 5D 04          CS MOV AH,B[BP+045D]
0D3E 8D B6 0B 00             LEA SI,[BP+0B]
0D42 B9 3F 04                MOV CX,043F
0D45 2E 30 24                CS XOR B[SI],AH
0D48 46                      INC SI
0D49 E2 FA                   LOOP 0D45
0D4B C3                      RET
0D4C B7 90                   MOV BH,090
