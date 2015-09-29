/* -----------------------------------------------------------------------------
 * Copyright © 2015, Numenta, Inc. Unless you have purchased from
 * Numenta, Inc. a separate commercial license for this software code, the
 * following terms and conditions apply:
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Affero Public License version 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero Public License for
 * more details.
 *
 * You should have received a copy of the GNU Affero Public License along with
 * this program. If not, see http://www.gnu.org/licenses.
 *
 * http://numenta.org/licenses/
 * -------------------------------------------------------------------------- */

'use strict';

import childProcess from 'child_process';
import EventEmitter from 'events';
import path from 'path';
import UserError from './UserError';

const MODEL_RUNNER_PATH = path.join(__dirname, '..', '..', 'backend',
                                    'unicorn_backend', 'model_runner.py');



/**
 * Thrown when attempting to create more models than allowed by the system
 */
export class MaximumConcurrencyError extends UserError {
  constructor() {
    super('Too many models running');
  }
};

/**
 * Thrown when attempting to create a model with the same ID as a previous model
 */
export class DuplicateIDError extends UserError {
  constructor() {
    super('Duplicate model ID');
  }
};

/**
 * Thrown when attempting to perform an operation on an unknown model
 */
export class ModelNotFoundError extends UserError {
  constructor() {
    super('Model not found');
  }
};

/**
 * Unicorn: ModelServer - Respond to a ModelClient over IPC, sharing our access
 * to Unicorn Backend Model Runner python and NuPIC processes.
 */
export class ModelServer extends EventEmitter {
  constructor() {
    super();
    this._models = new Map();
    // FIXME: UNI-149 - Remove hardcoded value. Use calculate concurrency value
    this._maxConcurrency = 2;
  }

  /**
   * Returns the number of slots available to run new models
   */
  availableSlots() {
    return this._maxConcurrency - this._models.size;
  }

  /**
   * Creates new HTM model
   * @param  {String}   modelId  Unique identifier for the model
   * @param  {Object}   stats    HTM Model parameters. See model_runner.py
   * @throws MaximumConcurrencyError, DuplicateIDError
   */
  createModel(modelId, stats) {
    if (this.availableSlots() <= 0) {
      throw new MaximumConcurrencyError();
    }
    if (this._models.has(modelId)) {
      throw new DuplicateIDError();
    }
    let child = childProcess.spawn('python', [MODEL_RUNNER_PATH, '--model',
                                              modelId, '--stats', stats]);
    child.stdout.setEncoding('utf8');
    child.stdin.setDefaultEncoding('utf8');
    child.stderr.setEncoding('utf8');

    child.on('error', (error) => {
      this.emit(modelId, 'error', error);
    });

    child.stderr.on('data', (error) => {
      this.emit(modelId, 'error', error);
    });

    child.stdout.on('data', (data) => {
      this.emit(modelId, 'data', data);
    });

    child.once('close', (code) => {
      this._models.delete(modelId);
      this.emit(modelId, 'close', code);
    });

    this._models.set(modelId,{
      modelId: modelId,
      stats: stats,
      child: child
    });
  }

  /**
   * Sends data to the model
   * @param {[String]} modelId   The model to send data
   * @param {[Array]} inputData The data values to be sent to the model,
   *                             usually in the following format:
   *                             '[timestamp, value]'
   * @throws ModelNotFoundError
   */
  sendData(modelId, inputData) {
    if (!this._models.has(modelId)) {
      throw new ModelNotFoundError();
    }
    let model = this._models.get(modelId);
    model.child.stdin.write(JSON.stringify(inputData) + '\n');
  }

  /**
   * Returns a list of active models
   * @return {Array} List of Model IDs with the active models
   */
  getModels() {
    return Array.from(this._models.keys());
  }

  /**
   * Stops and remove the model
   * @param  {String} modelId The model to stop
   * @return {Boolean}        True on success, false otherwise
   */
  removeModel(modelId) {
    if (!this._models.has(modelId)) {
      throw new ModelNotFoundError();
    }

    let model = this._models.get(modelId);
    this._models.delete(modelId);
    model.child.kill();
    this.removeAllListeners(modelId);
  }
};
