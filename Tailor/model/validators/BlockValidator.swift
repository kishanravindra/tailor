import Foundation

/**
  This method validates a model object by passing it to an arbitrary block.

  The block is responsible for setting errors on the model object if it fails
  the validation. It will be given the key and data used to initialize the
  validator.
  */
public class BlockValidator : Validator {
  /** The block to use to pass the model to for validation. */
  public let block : (Model, String)->()
  
  /**
    This method initializes a block validator with an empty block.
  
    The resulting validator would be useless, but we use this to support the
    initalizer from the parent class.
  
    :param: key   The key to validate.
    :param: data  Additional data for the validation.
    */
  public required init(key: String) {
    self.block = {(Model,String)->() in }
    super.init(key: key)
  }
  
  /**
    This method initializes a validator with a block.

    :param: key     The name of the property to validate.
    :param: data    Additional data to give to the block.
    :param: block   The block that will be doing the validation.
    */
  public required init(key: String, block: (Model, String)->()) {
    self.block = block
    super.init(key: key)
  }
  
  /**
    This method runs the block on a model object to validate it.

    :param: model   The model object to validate.
    */
  public override func validate(model: Model) {
    self.block(model, key)
  }
}