--
--  index-schema.sql
--  IDEFoundation
--
--  Created on 6/29/09.
--  Copyright 2009-2012 Apple Inc. All rights reserved.
--
CREATE TABLE provider (id INTEGER PRIMARY KEY AUTOINCREMENT, identifier TEXT NOT NULL, version TEXT NOT NULL);
--
CREATE TABLE file (id INTEGER PRIMARY KEY AUTOINCREMENT, lowercaseFilename INTEGER NOT NULL, filename INTEGER NOT NULL, directory INTEGER NOT NULL, inProject INTEGER NOT NULL);
CREATE INDEX file_lowercaseFilename_index ON file (lowercaseFilename);
--
CREATE TABLE unit (id INTEGER PRIMARY KEY AUTOINCREMENT, file INTEGER NOT NULL, target TEXT NOT NULL, provider INTEGER NOT NULL, pchFile INTEGER);
CREATE UNIQUE INDEX unit_index ON unit (file, target);
CREATE INDEX unit_target_index ON unit (target);
CREATE INDEX unit_provider_index ON unit (provider);
--
CREATE TABLE group_ (id INTEGER PRIMARY KEY AUTOINCREMENT, file INTEGER NOT NULL, signature TEXT NOT NULL, signature_inBody TEXT NOT NULL, provider INTEGER NOT NULL);
CREATE INDEX group_index ON group_ (file, signature);
--
CREATE TABLE context (unit INTEGER NOT NULL, group_ INTEGER NOT NULL, includer INTEGER, modified REAL, spliced INTEGER DEFAULT 0);
CREATE UNIQUE INDEX context_index ON context (unit, group_);
CREATE INDEX context_group_index ON context (group_);
CREATE INDEX context_includer_index ON context (includer);
--
CREATE TABLE symbol (id INTEGER PRIMARY KEY AUTOINCREMENT,
                     spelling INTEGER NOT NULL,
                     lowercaseSpelling INTEGER NOT NULL,
                     kind INTEGER,
                     role INTEGER NOT NULL,
                     language INTEGER,
                     resolution INTEGER,
                     group_ INTEGER NOT NULL,
                     lineNumber INTEGER,
                     column INTEGER,
                     locator TEXT,
                     container INTEGER,
                     completionString INTEGER);
CREATE INDEX symbol_lowercaseSpelling_index ON symbol (lowercaseSpelling);
CREATE INDEX symbol_resolution_index ON symbol (resolution);
CREATE INDEX symbol_kind_index ON symbol (kind);
CREATE INDEX symbol_group_index ON symbol (group_);
CREATE INDEX symbol_container_index ON symbol (container);
--
-- container column gives the lexical container from the symbol table.
CREATE TABLE reference (id INTEGER PRIMARY KEY AUTOINCREMENT,
                        spelling INTEGER NOT NULL,
                        lowercaseSpelling INTEGER NOT NULL,
                        kind INTEGER,
                        role INTEGER NOT NULL,
                        language INTEGER,
                        resolution INTEGER,
                        group_ INTEGER NOT NULL,
                        lineNumber INTEGER,
                        column INTEGER,
                        locator TEXT,
                        container INTEGER,
                        receiver INTEGER);
CREATE INDEX reference_lowercaseSpelling_index ON reference (lowercaseSpelling);
CREATE INDEX reference_resolution_index ON reference (resolution);
CREATE INDEX reference_group_index ON reference (group_);
CREATE INDEX reference_container_index ON reference (container);
--
CREATE TABLE kind (id INTEGER PRIMARY KEY AUTOINCREMENT, identifier TEXT NOT NULL);
--
CREATE TABLE language (id INTEGER PRIMARY KEY AUTOINCREMENT, identifier TEXT NOT NULL);
